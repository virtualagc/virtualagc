import sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import crewscript
from scriptclock import ScriptClock

class Timing(unittest.TestCase):
    def run_steps(self, rate, stalled=False):
        wall=[0.0]; pending=[]; result=[]
        clock=ScriptClock(wall=lambda:wall[0],rate=lambda:rate)
        player=crewscript.Player(crewscript.parse('+1 thc aft +x 0.30\n+1 thc aft +x 0.30\n','test'),lambda ms,fn:pending.append((wall[0]+ms/1000,fn)),lambda v,a:result.append(wall[0]*rate),lambda _: 'RUN',lambda _:None,bus=object(),clock=clock)
        player.start()
        for _ in range(1000):
            if not pending:break
            pending.sort(key=lambda x:x[0]);due,fn=pending.pop(0)
            wall[0]=max(due,2.0 if stalled and not result else due);fn()
        return result
    def test_rate_four_spacing(self):
        a,b=self.run_steps(4);self.assertAlmostEqual(a,1,delta=.01);self.assertAlmostEqual(b-a,1,delta=.01)
    def test_late_dispatch_does_not_collapse_train(self):
        a,b=self.run_steps(4,True);self.assertAlmostEqual(b-a,1,delta=.01)
    def test_rate_change_keeps_clock_continuous(self):
        wall=[0.0];rate=[1.0];c=ScriptClock(wall=lambda:wall[0],rate=lambda:rate[0]);wall[0]=2;self.assertEqual(c.now(),2);rate[0]=4;self.assertEqual(c.now(),2);wall[0]=3;self.assertEqual(c.now(),6)
    def test_hold_expiry_vehicle_seconds(self):
        import handcontrollers as hc
        import threading
        wall=[0.0];clock=ScriptClock(wall=lambda:wall[0],rate=lambda:4.0)
        obj=object.__new__(hc.ScriptInput);obj.clock=clock;obj.lock=threading.Lock();obj.thc={'+X':clock.now()+.30};obj.rhc={}
        self.assertTrue(obj.apply(0,[0,0,0])[0]);wall[0]=.08;self.assertEqual(obj.apply(0,[0,0,0])[0],0)
    def test_scheduled_release_changes_rate(self):
        wall=[0.0];rate=[1.0];pending=[];done=[]
        c=ScriptClock(wall=lambda:wall[0],rate=lambda:rate[0])
        c.schedule(lambda ms,fn:pending.append((wall[0]+ms/1000,fn)),1,lambda:done.append(c.now()))
        for _ in range(100):
            if not pending:break
            pending.sort(key=lambda x:x[0]);wall[0],fn=pending.pop(0)
            if wall[0]>=.3:rate[0]=4
            fn()
        self.assertEqual(len(done),1);self.assertAlmostEqual(done[0],1,delta=.01)

    def test_rate_one_spacing(self):
        a,b=self.run_steps(1);self.assertAlmostEqual(a,1,delta=.01);self.assertAlmostEqual(b-a,1,delta=.01)
    def test_missing_rate_file_defaults_to_one(self):
        import os
        from unittest.mock import patch
        from scriptclock import runtime_rate
        with patch.dict(os.environ, {'YAGPC_RATE_FILE':'/tmp/no-such-task-k-rate-file'}):
            self.assertEqual(runtime_rate(),1)

    def test_actual_vehicle_clock_overrides_requested_rate(self):
        wall=[0.0];vehicle=[10.0]
        c=ScriptClock(wall=lambda:wall[0],rate=lambda:8.0,vehicle=lambda:vehicle[0])
        self.assertEqual(c.now(),0)
        wall[0]=1;vehicle[0]=14;self.assertEqual(c.now(),4)
        wall[0]=2;self.assertEqual(c.now(),4)
        vehicle[0]=None;wall[0]=3;self.assertEqual(c.now(),4)
        vehicle[0]=15;self.assertEqual(c.now(),5)

if __name__=='__main__':unittest.main()


