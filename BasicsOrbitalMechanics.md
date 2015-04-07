![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)

# 1. Orbital Mechanics Introduction #
The intention of this section is to introduce you to some very basic concepts of orbital mechanics. At the end of this section you should be able to calculate some orbital parameters, understand how to change orbits (i.e. change in velocity to obtain a new orbit) and how to calculate burn times to achieve the new orbit. This will be useful when using the LGC simulation to change orbits. The calculations in this section use basic methods and don't incorporate any irregularities of the orbiting body (.e.g. mascons on the moon).

## 1.1 What is an Orbit ##
An orbit is the movement of a (small body) object around a usually much larger body (e.g. planet or moon) in space in the shape of an elliptical. The elliptical shape is determined by the velocity of the small body and its distance to the center of gravity of the larger body. The location of the closest and farthest point of an orbiting object around a body is fixed irrespective of the larger bodies rotation. This brings up the difference between a revolution and an orbit. A revolution is defined relative to a position on the body that you are orbiting. For example since the Earth turns around its axis a revolution around the Earth will be more then an orbit if you orbit in the direction of the rotation. So the time to complete an orbit may not be the same as the revolution time. An object in orbit is continuously falling towards the body that it is orbiting but because of its velocity never reaches the surface. When an object moves in an elliptical orbit there will be a point where it is closest (periapsis) to the body it orbits and a point where it is farthest (apoapsis). When in apoapsis the object has its slowest speed in the orbit and will start falling back to the body and exchange potential energy for kinetic energy. If the object travels to slow at a certain distance then its path will intersect with the object it was orbiting or if it travels to fast at a certain distance then it will never return (a.k.a escape velocity). Depending on the body that is being orbited the names of the closest and farthest approach change their suffix (e.g. apogee and perigee when orbiting the Earth, aphelion and perihelion when orbiting the Sun and apolune and perilune when orbitting the Moon).

## 1.2 Orbital Math ##
To determine orbit parameters of an object (e.g. spacecraft) one needs to understand some basic math and definitions of an elliptical orbit. Since this project provides an LM simulator lets assume for reference that our spacecraft is orbiting the Moon. The distance between the perilune and apolune is called the major axis and half of this distance is known as the semi-major axis. If we define the semi-major axis to be equal to _a_ then the major axis equals _2a_. Each point of the orbit has a distance _r_ to the center of the attracting body (e.g. Moon). The distance where the spacecraft is closest to the center of the attracting body will be referred to as _r<sub>p</sub>_ (i.e. in perilune) and the furthest distance (i.e. in apolune) _r<sub>a</sub>_ and so:

> _r<sub>a</sub>_ + _r<sub>p</sub> =_2a_._

The measure of how elliptical an orbit is is expressed with eccentricity _e_. If _e = 0_ we have a perfect circular orbit. For _e < 1_ we have an eliptical orbit and when _e = 1_ we have reached escape velocity and _e > 1_ means we are no longer in orbit; the spacecraft will never return. The eccentricity has the following relation with _r<sub>a</sub>_ and _r<sub>p</sub>_

> _r<sub>a</sub>_ = _a_( 1 - _e_ )

> _r<sub>p</sub>_ = _a_( 1 + _e_ )

Now we have enough to calculate the velocity _v_ at perilune and apolune if we desire an orbit that has a a closest approach of 100km above the surface of the Moon and a fartest piont of 500km above the surface. Since the Moon has an average radius of 1738 km (i.e. 1738000 m) we can now determine _r<sub>a</sub>_ and _r<sub>p</sub>._ and _a_

> _r<sub>a</sub>_ = 2238000 m

> _r<sub>p</sub>_ = 1838000 m

> _a_ = ( _r<sub>a</sub>_ + _r<sub>p</sub>_ ) / 2 = ( 2238000 m + 1838000 m ) / 2 = 2038000 m

Now we can determine if this orbit is actually stable with regards to these parameters

> _e_ =   _r<sub>a</sub>_ / _a_ - 1

> _e_ =  -_r<sub>p</sub>_ / _a_ + 1

> _e_ = 0.098135

Since the eccentricity is less than 1 the orbit is stable and achievable.

To calculate the velocity in at either apolune or perilune we need the gravitational parameter _u_ for the body we are orbiting (i.e. 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ) and the following formula:

> _v_ = **SQRT**( _u_ ( 2 / _r<sub>x</sub>_ - 1 / _a_ ) )

where:
  * _r<sub>x</sub>_ is is the distance to the center of the orbiting body.

So the velocity at perilune (i.e. 100km above the lunar surface) is:

> _v_ = **SQRT**( 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ( 2 / 1838000 m - 1 / 2038000 m ) ) = 1711.013 m/s

### 1.2.1 Changing Orbit Altitude ###
To change orbits (i.e. its altitude) is quite easy as long as you know when to start a burn and how much change in velocity is required to end up in the new orbit. When you know your current orbit and the new desired orbit then all you have to do is wait untill both orbits intersect. Typically maneuvers are executed in either periapsis or apoapsis. Especially if you want to circularize your orbit. Lets assume for the following example that we are in lunar orbit once again but this time in a circular orbit at 100 km above the surface and we want to lower our orbit to a circular 50 km orbit. This will require 2 burns to accomplish. The first burn will change the orbit from a cirular to an eliptical orbit with its perilune at 50 km and its apolune at 100 km. The second burn would lower the apolune so that both apolune and perilune are 50 km. The previous section has shown how to calculate the velocity of the spacecraft in both apolune and perilune. We use the same methods in this section to determine the velocities of both perilune and apolune for all three orbits and from there we can derive the change in velocity commonly known as _Delta-V_.

Since the first orbit is circular we know that _e_ = 0 and that that the velocity in both the perilune and apolune are equal:

> _a_ = _r<sub>a</sub>_ = _r<sub>p</sub>_ = 100 km + 1738 km = 1838 km

> _v_ = **SQRT** ( 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ( 2 / 1838000 m - 1 / 1838000 ) ) = 1632.771 m/s

This velocity is also the apolune of our intermediate orbit (i.e. 100 km by 50 km). Since it is the apolune of our new orbit it means that we have to reduce our velocity to a value that will have the apolune of 100 km and a perilune of 50 km. Since we are lowering our orbit we must fire against are path of travel (retrograde). To determine the change in velocity we just calculate the velocity for the apolune of this new orbit.

> _r<sub>a</sub>_ = 1838000 m

> _r<sub>p</sub>_ = 1788000 m

> _a_ = (_r<sub>a</sub>_ + _r<sub>p</sub>_) / 2 = 1813000 m

> _v<sub>a</sub>_ = **SQRT** ( 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ( 2 / 1838000 m - 1 / 1813000 ) = 1621.475 m/s

> _v<sub>p</sub>_ = **SQRT** ( 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ( 2 / 1788000 m - 1 / 1813000 ) = 1666.818 m/s


Now that we have the new velocities we determine _Delta-V<sub>a</sub>_:

> _Delta-V<sub>a</sub>_ = 1621.475 m/s - 1632.771 m/s = -11.296 m/s

To accomplish this change in velocity we must ignite the engine at the right moment at burn for a certain amount of time (see next section) based on the performance of the rocket engine. Since we wanted to get into a lower circular orbit (50km above the surface) it is necessary to once again execute a burn but now at the new perilune. This burn must be again retrograde since we are lowering the orbit. Again we use the same method to determine the velocities for the new orbit:

> _a_ = _r<sub>a</sub>_ = _r<sub>p</sub>_ = 1788000 m (The orbit is circular)

> _v_ = **SQRT** ( 4.9\*10<sup>12</sup> m<sup>3</sup>/s<sup>2</sup> ( 2 / 1788000 m - 1 / 1788000 ) = 1655.443 m/s

> _Delta-V<sub>p</sub>_ = 1655.443 m/s - 1666.818 m/s = -11.375 m/s

The Delta-V can be used to determine for how long we must fire the rocket engine and how much propellant will be consumed (see respective section below)

### 1.2.1 Changing Orbit Plane ###
Changing the plane of the orbit is also not difficult as long as we stick with some basic assumptions that must hold for the math in this section: The orbit must be circular (so if it is not first circularize your orbit) and we only change the plane of the orbit and not its altitude at the same time. This is known as a pure plane change maneuver. This maneuver is executed when you want to change the declanation of your orbit or when you want to align the orbit of the spacecraft with a target body to reach (e.g. change to the same plane as the Moon before executing the Translunar Injection (TLI)). The burn is typically executed over the equator of the orbiting body but isn't mandatory. However the burn must be executed in the node where both the old and new orbit intersect. Since the orbits are circular there are two points in the current orbit where this can occur. The attitude of the spacecraft must be such that the thrust vector is perpendicular to the direction of travel. The _Delta-V_ required for this burn:

> _Delta-V_ = 2 · _v<sub>cir</sub>_ · sin (½ · _i<sub>change</sub>_)

where:
  * _v<sub>cir</sub>_ is the orbital velocity (both orbits  are circular and both have the same speed)
  * _i<sub>change</sub>_ is the change in inclination between the old and new orbit.

So if we are in the 50 km orbit around the moon with an orbital velocity of 1655.443 m/s we would need the following Delta-V perpendicular to our direction of travel to reach a 4° change in inclination:

> _Delta-V_ = 2 · 1655.443 m/s · sin (2°) = 115.548 m/s

From the formula you can also find that any plane equal or larger than 60° (i.e. sin(30°) = 0.5 ) requires as much Delta-V as the current orbital velocity and you may have just as well relaunched with a new rocket in the desired plane. The _Delta-V_ determined here can now be used to calculate fuel consumption and burn time.

## 1.3 Propellant and Burn time ##
A rocket engine can be characterized by two major parameters: thrust and specific impulse. You might think that if you give the spacecraft a bigger engine (more thrust) that it is then easier to make the change in velocity. That is true, it will take less time. But the real interest of the engineers is the amount of propellant you use for a certain change in velocity and that is what the specific impulse tells you. Specific impulse of a rocket engine conveys its performance just like miles per gallon does for a combustion engine in a vehicle. The higher the specific impulse the more effective the thrust is. The LM has a descent engine with a specific impulse of about 311 seconds and a thrust of 45.04 kN. With the engine performance and the Delta-V values we can determine the burn time and amount of propellant that is needed using Konstantin Tsiolkovsky's formula.

Tsiolkovsky's formula indicates how much propellant is needed to perform the Delta-V burn with a given engine for a given spacecraft mass:

> _Delta-V_ = _I<sub>sp</sub>_ _g_ **ln**( _M<sub>initial</sub>_ /  _M<sub>end</sub>_ )

In this formula g = 9.81 m/s<sup>2</sup> is the acceleration at Earth and _I<sub>sp</sub>_ the specific impulse of the rocket engine. Since we know Delta-V (use the absolute value) we can determine _M<sub>end</sub>_.

> _M<sub>end</sub>_ = _M<sub>initial</sub>_ / **e** <sup>Delta-V / (Isp · g)</sup>

where:
  * **e** = the natural number i.e. 2.71828 and not eccentricity.

Lets assume we have a LM in landing configuration, which means a mass of 15004 kg and we use the DPS (Descent Propulsion System) engine to change our orbits.

> _M<sub>end</sub>_ = 15004 kg / e <sup>11.296 m/s / (311 s · 9.81 m/s²)</sup> = 14948.55 kg

So the change in mass is 15004 kg - 14948.55 kg = 55.45 kg for our first burn. To calculate fuel consumption per second we need to know the thrust and specific impulse _I<sub>sp</sub>_:

> fuel consumption per second = thrust / (_I<sub>sp</sub>_ · g)

> fuel consumption per second = 45040 / (311 · 9.81) =  14.763 kg/s

Now we can just take the amount of fuel consumed for the Delta-V and divide that by the rate of consumption and we find that this burn would take 3.76 seconds:

> burn time = 55.45 kg / 14.763 kg/s = 3.76 s

Now for the next burn you must take the new mass of the LM 14948.55 Kg and the Delta-V for the next burn and follow the same steps as the first burn to determine the second burn time for the DPS engine. With the above knowledge you should be able to not only change orbits around a body but also have the tool set for some very simplistic Homann transfers to leave one orbiting body for another (e.g. leave the Earth to go to the moon).

## 1.4 Injection versus Insertion ##
When you leave the influence of one attracting body for another you must first inject the spacecraft into a trajectory to **intercept** the other body and then **insert** into an orbit. So insertion is to get into orbits and injection is used for a trajectory even though in all cases you are technically just changing orbits usually very elliptical to intersect with another attacking body.