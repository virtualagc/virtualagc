import sys,unittest,itertools
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))

import joystick_profiles as profiles
import handcontrollers as old
class Stick:
 def __init__(self,axes,hat=(0,0),buttons=(),name='Logitech Extreme 3D Pro',guid='test'):self.axes=axes;self.hat=hat;self.buttons=buttons;self.name=name;self.guid=guid
 def get_axis(self,i):return self.axes[i]
 def get_numaxes(self):return len(self.axes)
 def get_hat(self,i):return self.hat
 def get_numhats(self):return 1
 def get_numbuttons(self):return 12
 def get_button(self,i):return i+1 in self.buttons
 def get_name(self):return self.name
 def get_guid(self):return self.guid
class Tests(unittest.TestCase):
 def test_legacy_equivalence(self):
  profile=profiles.legacy_profile(old.DEFAULT_MAP)
  for axes,hat,buttons,seen in itertools.product([(0,0,0),(-1,.2,.05),(.6,-.4,1)],[(0,0),(-1,1),(1,-1)],[(),(3,),(5,),(3,5)],[None,set(),{0,2}]):
   js=Stick(axes,hat,buttons);new=profiles.ProfileState().read(js,profile,seen)
   self.assertEqual(new,(old.thc_bits(js,old.DEFAULT_MAP),old.rhc_counts(js,old.DEFAULT_MAP,seen)))
 def test_merge_cancel_and_clip(self):
  bits,c=profiles.merge([(profiles.THC_BITS['+X'],{'roll':30000}),(profiles.THC_BITS['-X'],{'roll':30000})]);self.assertEqual(bits,0);self.assertEqual(c['roll'],32000)
 def test_hysteresis(self):
  state=profiles.ProfileState();self.assertEqual([state.axis_contact('X',v) for v in [.49,.51,.4,.34,-.51,-.4,-.34]],[0,256,256,0,128,128,0])
 def test_role_renumbering(self):
  a=Stick([0]*3);b=Stick([0]*3,name='T.16000M',guid='second');roles={'rhc':{'match':'Extreme'},'thc':{'guid':'second'}}
  self.assertEqual(profiles.resolve_roles({0:a,1:b},roles),{'rhc':0,'thc':1});self.assertEqual(profiles.resolve_roles({0:b,1:a},roles),{'rhc':1,'thc':0})
 def test_offset_scale(self):
  profile={'axes':{'0':{'to':'rhc.roll','offset':.2,'scale':2,'sign':-1,'deadband':0}}};self.assertEqual(profiles.ProfileState().read(Stick([.5]),profile)[1]['roll'],-19200)
 def test_unseen_axis_is_detent(self):
  p={'axes':{'0':{'to':'thc.X','offset':-.5}}};self.assertEqual(profiles.ProfileState().read(Stick([-1]),p,set())[0],0)
if __name__=='__main__':unittest.main()
