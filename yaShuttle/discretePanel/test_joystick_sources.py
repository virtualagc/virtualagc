import unittest,json,tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
from joystick_sources import Sources
from test_joystick_profiles import Stick
import handcontrollers as hc
class Device(Stick):
 def __init__(self,*a,ident=1,**kw):super().__init__(*a,**kw);self.ident=ident
 def init(self):pass
 def get_instance_id(self):return self.ident
class System:
 def __init__(self,devices):self.devices=devices
 def get_count(self):return len(self.devices)
 def Joystick(self,index):return self.devices[index]
class Tests(unittest.TestCase):
 def source(self,devices,config=None):
  p=SimpleNamespace(error=RuntimeError,joystick=System(devices),JOYDEVICEADDED=1,JOYDEVICEREMOVED=2,JOYAXISMOTION=3,JOYHATMOTION=4)
  args=SimpleNamespace(joysticks=None,config='legacy-explicit',joystick=0,thc_joystick=None,probe=False)
  s=Sources(p,args,hc.DEFAULT_MAP,lambda _:None)
  if config:s.config=config
  return s,p
 def test_disconnect_releases(self):
  d=Device([0,0,0]);s,p=self.source([d]);s.read();d.axes[0]=1;s.next_scan=0;self.assertEqual(s.read()[1]['roll'],32000)
  p.joystick.devices=[];s.next_scan=0;self.assertEqual(s.read()[1]['roll'],0)
 def test_replug_role_by_guid_resets_unmoved(self):
  a=Device([0,0,0],guid='r',ident=1);b=Device([0,0,0],name='THC',guid='t',ident=2)
  config={'roles':{'rhc':{'guid':'r'},'thc':{'guid':'t'}}};s,p=self.source([a,b],config);s.read();a.axes[0]=.5;self.assertGreater(s.read()[1]['roll'],0)
  p.joystick.devices=[Device([0,0,0],name='THC',guid='t',ident=3),Device([.5,0,0],guid='r',ident=4)];s.next_scan=0
  self.assertEqual(s.read()[1]['roll'],0);self.assertEqual(s.last_roles,{'rhc':1,'thc':0})
 def test_second_stick_and_legacy_hat_merge(self):
  a=Device([0,0,0]);b=Device([0,0,0],name='THC',ident=2);s,p=self.source([a,b]);s.args.thc_joystick=1;s.read();a.hat=(-1,0);b.axes[0]=.7
  self.assertEqual(s.read()[0],0) # RHC hat -Y cancels second-stick +Y.
 def test_listing_reports_capabilities_and_role(self):
  s,p=self.source([Device([0,0,0])]);row=s.listing()[0];self.assertEqual(row['roles'],['rhc']);self.assertEqual(row['axes'],3)
 def test_two_logitechs_second_defaults_to_thc(self):
  a=Device([0,0,0],ident=1);b=Device([0,0,0],ident=2)
  config={'roles':{'rhc':{'match':'Extreme'}},'sticks':{'Extreme':__import__('joystick_profiles').legacy_profile(hc.DEFAULT_MAP)}}
  s,p=self.source([a,b],config);s.args.thc_joystick=1;s.read();b.axes[1]=-.7
  bits,counts=s.read();self.assertEqual(bits,hc.THC_BITS['+X']);self.assertEqual(counts['pitch'],0)

if __name__=='__main__':unittest.main()
