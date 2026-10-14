"""Pure joystick profile transforms, role resolution, and source merging."""
import math
THC_BITS={'+X':0x100,'-X':0x80,'+Y':0x40,'-Y':0x20,'+Z':0x10,'-Z':0x08}
RHC_AXES=('roll','pitch','yaw');RHC_FULL=32000

def merge(sources):
    bits=0;counts={axis:0 for axis in RHC_AXES}
    for b,c in sources:
        bits|=b
        for axis in counts:counts[axis]+=c.get(axis,0)
    for axis in 'XYZ':
        mask=THC_BITS['+'+axis]|THC_BITS['-'+axis]
        if bits&mask==mask:bits&=~mask
    return bits,{a:max(-RHC_FULL,min(RHC_FULL,v)) for a,v in counts.items()}

def matches(js,index,selector):
    if 'index' in selector and selector['index']!=index:return False
    if 'guid' in selector and selector['guid']!=js.get_guid():return False
    if 'match' in selector and selector['match'].lower() not in js.get_name().lower():return False
    return bool(selector)

def resolve_roles(sticks,roles):
    result={}
    for role,selector in roles.items():
        found=[i for i,js in sticks.items() if matches(js,i,selector)]
        if len(found)>1:raise ValueError(f'ambiguous {role} joystick selection: {found}')
        result[role]=found[0] if found else None
    return result

def profile_for(name,profiles):
    found=[(pattern,profile) for pattern,profile in profiles.items() if not pattern.startswith('_') and pattern.lower() in name.lower()]
    if not found:return None
    found.sort(key=lambda item:len(item[0]),reverse=True)
    if len(found)>1 and len(found[0][0])==len(found[1][0]):raise ValueError('ambiguous joystick profile')
    return found[0][1]

def legacy_profile(mapping):
    return dict(axes={str(mapping['rhc_axis'][a]):dict(to='rhc.'+a,sign=mapping['rhc_sign'][a],deadband=mapping['rhc_deadband']) for a in RHC_AXES},hat=dict(left=mapping['hat_x'][0],right=mapping['hat_x'][1],down=mapping['hat_y'][0],up=mapping['hat_y'][1]),buttons=mapping['buttons'])

class ProfileState:
    def __init__(self):self.contacts={}
    def axis_contact(self,axis,value,threshold=.5,hysteresis=.15):
        if not 0<threshold<=1 or not 0<=hysteresis<threshold:raise ValueError('invalid contact threshold/hysteresis')
        old=self.contacts.get(axis,0);off=threshold-hysteresis
        if value>=threshold:new=1
        elif value<=-threshold:new=-1
        elif old==1 and value>off:new=1
        elif old==-1 and value<-off:new=-1
        else:new=0
        self.contacts[axis]=new
        return THC_BITS[('+' if new>0 else '-')+axis] if new else 0
    def read(self,js,profile,seen=None,hat_seen=True):
        bits=0;counts={a:0 for a in RHC_AXES}
        for key,entry in profile.get('axes',{}).items():
            i=int(key);active=i<js.get_numaxes() and (seen is None or i in seen)
            raw=js.get_axis(i) if active else 0.0
            if not active:
                if entry['to'].startswith('thc.'):self.contacts[entry['to'][4:].upper()]=0
                continue
            value=(raw-entry.get('offset',0))*entry.get('scale',1)*entry.get('sign',1)
            if not math.isfinite(value):raise ValueError('nonfinite joystick axis')
            value=max(-1,min(1,value));target=entry['to']
            if target.startswith('rhc.'):
                axis=target[4:]
                if axis not in counts:raise ValueError('unknown RHC axis')
                db=entry.get('deadband',.05)
                if not 0<=db<1:raise ValueError('invalid deadband')
                value=0 if abs(value)<db else math.copysign((abs(value)-db)/(1-db),value)
                counts[axis]+=round(value*RHC_FULL)
            elif target.startswith('thc.'):
                axis=target[4:].upper()
                if axis not in 'XYZ' or len(axis)!=1:raise ValueError('unknown THC axis')
                bits|=self.axis_contact(axis,value,entry.get('threshold',.5),entry.get('hysteresis',.15))
            else:raise ValueError('unknown axis destination')
        if hat_seen and js.get_numhats():
            x,y=js.get_hat(0)
            for pressed,name in [(x<0,'left'),(x>0,'right'),(y<0,'down'),(y>0,'up')]:
                if pressed and name in profile.get('hat',{}):bits|=THC_BITS[profile['hat'][name]]
        for key,direction in profile.get('buttons',{}).items():
            button=int(key)-1
            if 0<=button<js.get_numbuttons() and js.get_button(button):bits|=THC_BITS[direction]
        return merge([(bits,counts)])
