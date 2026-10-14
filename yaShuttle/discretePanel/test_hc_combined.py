import unittest
from types import SimpleNamespace
from unittest.mock import patch,Mock
import handcontrollers as hc
class Virtual:
 def __init__(self,*args):self.scripted=False;self.drawn=[]
 def handle(self,event):pass
 def sync_focus(self):pass
 def deflection(self):return {'roll':.5,'pitch':0,'yaw':0}
 def thc_bits(self):return hc.THC_BITS['+X']
 def draw(self,*args):self.drawn.append(args)
class Tests(unittest.TestCase):
 def test_event_keyerror_survives_and_sources_merge(self):
  events=Mock();events.get.side_effect=[KeyError(0),[SimpleNamespace(type=9)]]
  pg=SimpleNamespace(event=events,error=RuntimeError,JOYDEVICEADDED=1,JOYDEVICEREMOVED=2,QUIT=9,time=SimpleNamespace(Clock=lambda:SimpleNamespace(tick=lambda hz:None)))
  args=SimpleNamespace(style='gimbal',size=384,rhc='lh',thc='fwd')
  physical=Mock();physical.read.return_value=(hc.THC_BITS['-X'],{'roll':20000,'pitch':0,'yaw':0})
  pub=SimpleNamespace(bits=0,send=Mock());rp=SimpleNamespace(counts={},send=Mock());status=SimpleNamespace(show=Mock())
  with patch.object(hc,'VirtualControls',Virtual),patch.object(hc,'log'):
   self.assertEqual(hc.run_virtual(pg,args,pub,rp,status,physical=physical),0)
  self.assertEqual(pub.bits,0);self.assertEqual(rp.counts['roll'],hc.RHC_FULL);pub.send.assert_called_once();events.set_allowed.assert_called_once()
 def test_virtual_exclusive_blocks_device_events(self):
  events=Mock();events.get.return_value=[SimpleNamespace(type=9)]
  pg=SimpleNamespace(event=events,error=RuntimeError,JOYDEVICEADDED=1,JOYDEVICEREMOVED=2,QUIT=9,time=SimpleNamespace(Clock=lambda:SimpleNamespace(tick=lambda hz:None)))
  args=SimpleNamespace(style='gimbal',size=384,rhc='lh',thc='fwd')
  with patch.object(hc,'VirtualControls',Virtual),patch.object(hc,'log'):
   self.assertEqual(hc.run_virtual(pg,args,Mock(),Mock(),Mock()),0)
  events.set_blocked.assert_called_once()
if __name__=='__main__':unittest.main()
