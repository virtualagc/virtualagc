"""Hot-plug joystick sources shared by windowed and windowless controls."""
import json,time
from pathlib import Path
from joystick_profiles import ProfileState,legacy_profile,profile_for,resolve_roles,merge

class Sources:
    def __init__(self,pg,args,mapping,log):
        self.pg,self.args,self.mapping,self.log=pg,args,mapping,log
        self.devices={};self.next_scan=0;self.next_probe=0;self.last_roles=None
        self.config={}
        paths=[Path(args.joysticks)] if args.joysticks else [Path.home()/'.config/nsts/joysticks.json',Path(__file__).parent/'examples/joysticks.json']
        if args.config and not args.joysticks:paths=[] # Explicit legacy overrides remain effective.
        for p in paths:
            if p.is_file():
                self.config=json.loads(p.read_text());self.log('joystick profiles: '+str(p));break
        if args.joysticks and not self.config:raise ValueError('joystick profile file not found or empty')
    def scan(self,force=False):
        now=time.monotonic()
        if not force and now<self.next_scan:return
        self.next_scan=now+.5;new={}
        for index in range(self.pg.joystick.get_count()):
            try:
                js=self.pg.joystick.Joystick(index)
                if not getattr(self.pg,'IS_CE',False):js.init()
                ident=js.get_instance_id()
                record=self.devices.get(ident)
                if record is None:
                    record={'js':js,'seen':set(),'hat_seen':False,'state':ProfileState(),'initial':[js.get_axis(i) for i in range(js.get_numaxes())],'initial_hat':js.get_hat(0) if js.get_numhats() else (0,0)}
                    self.log(f'joystick {index}: {js.get_name()} guid={js.get_guid()} axes={js.get_numaxes()} buttons={js.get_numbuttons()} hats={js.get_numhats()}')
                record['index']=index;new[ident]=record
            except self.pg.error:continue
        for ident in self.devices.keys()-new.keys():self.log('joystick removed: '+str(ident))
        self.devices=new
    def events(self,events):
        for event in events:
            if event.type in (self.pg.JOYDEVICEADDED,self.pg.JOYDEVICEREMOVED):self.next_scan=0
            record=self.devices.get(getattr(event,'instance_id',None))
            if record is None:
                record=next((r for r in self.devices.values() if r['index']==getattr(event,'joy',None)),None)
            if record:
                if event.type==self.pg.JOYAXISMOTION:
                    value=getattr(event,'value',record['js'].get_axis(event.axis))
                    if event.axis in record['seen'] or value!=record['initial'][event.axis]:record['seen'].add(event.axis)
                if event.type==self.pg.JOYHATMOTION:record['hat_seen']=True
    def read(self):
        self.scan();sticks={r['index']:r['js'] for r in self.devices.values()}
        selectors=dict(self.config.get('roles',{'rhc':{'index':self.args.joystick}}))
        if self.args.thc_joystick is not None:selectors['thc']={'index':self.args.thc_joystick}
        if getattr(self.args, '_joystick_explicit', False):selectors['rhc']={'index':self.args.joystick}
        roles={}
        for role,selector in selectors.items():
            candidates=sticks
            if role=='rhc' and 'index' not in selector and self.args.thc_joystick is not None:
                candidates={i:js for i,js in sticks.items() if i!=self.args.thc_joystick}
            roles.update(resolve_roles(candidates,{role:selector}))
        if roles!=self.last_roles:self.log('joystick roles: '+str(roles));self.last_roles=roles
        sources=[]
        for r in self.devices.values():
            js=r['js'];role_names=[name for name,i in roles.items() if i==r['index']]
            if not role_names:continue
            for i,value in enumerate(r['initial']):
                if js.get_axis(i)!=value:r['seen'].add(i)
            if js.get_numhats() and js.get_hat(0)!=r['initial_hat']:r['hat_seen']=True
            profile=profile_for(js.get_name(),self.config.get('sticks',{}))
            if profile is None:
                profile=legacy_profile(self.mapping) if 'rhc' in role_names else {'axes':{'0':{'to':'thc.Y'},'1':{'to':'thc.X','sign':-1},'2':{'to':'thc.Z'}}}
            if 'thc' in role_names and not any(e.get('to','').startswith('thc.') for e in profile.get('axes',{}).values()):
                thc_profile={'axes':{'0':{'to':'thc.Y'},'1':{'to':'thc.X','sign':-1},'2':{'to':'thc.Z'}},'hat':profile.get('hat',{}),'buttons':profile.get('buttons',{})}
                if 'rhc' not in role_names:profile=thc_profile
                else:sources.append(r['state'].read(js,thc_profile,r['seen'],r['hat_seen']))
            r['resolved_profile']=profile
            sources.append(r['state'].read(js,profile,r['seen'],r['hat_seen']))
        if self.args.probe and time.monotonic()>=self.next_probe:
            self.next_probe=time.monotonic()+.2
            for r in self.devices.values():
                js=r['js'];self.log(f"probe {r['index']} {js.get_name()} axes={[js.get_axis(i) for i in range(js.get_numaxes())]} hats={[js.get_hat(i) for i in range(js.get_numhats())]} buttons={[i+1 for i in range(js.get_numbuttons()) if js.get_button(i)]}")
        return merge(sources)
    def listing(self):
        self.scan(True);self.read()
        return [dict(index=r['index'],name=r['js'].get_name(),guid=r['js'].get_guid(),axes=r['js'].get_numaxes(),buttons=r['js'].get_numbuttons(),hats=r['js'].get_numhats(),roles=[k for k,v in (self.last_roles or {}).items() if v==r['index']],profile=r.get('resolved_profile')) for r in self.devices.values()]
