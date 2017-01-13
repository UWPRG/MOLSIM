import numpy as np
import scipy as sp
import pandas as pd
import matplotlib.pyplot as plt
import pdb

def init(temp,dt):
    xi=np.random.rand(1) # generate random configuration
    vi=np.random.randn(1) # generate random velocity
    sumv=vi
    sumv2=vi**2
    scale_factor=np.sqrt(1*temp/sumv2) # calculate scale factor for temperature
    vi=vi*scale_factor # re-scale velocity to temperature (via equipartition theorem)
    xprev=xi-vi*dt # estimate previous location using velocity
    return xi,xprev,vi

def calcforce(xi):
    ener=0.5*(xi-1)**2# calculate energy (harmonic oscillator)
    force=(-1*xi+1) # -dU/dx
    return ener,force

def integrate(xi,xprev,force,epot,delt):
    newx=xi*2-xprev+force*delt**2 # verlet algorithm
    newv=(newx-xprev)/(2*delt) # estimate new velocity
    temp=newv**2 # calculate temperature assume m,k=1 and 1-D so 1/2T=1/2v^2
    etot=epot+0.5*newv**2 # Total = Potential + Kinetic
    kin=0.5*newv**2 # Kinetic Energy = 1/2v^2
    return newx,temp,etot,kin


base=np.arange(-1,3,0.01)
positions=np.zeros(50000)
temp=np.zeros(len(positions))
etot=np.zeros(len(positions))
eptot=np.zeros(len(positions))
ekin=np.zeros(len(positions))
temp[0]=1 #change
dt=0.1 #change
pdb.set_trace()
x0,xp,v0=init(temp[0],dt)
velocities=np.zeros(len(positions))

#positions[0]=xp
positions[0]=x0
velocities[0]=v0

eptot[0]=calcforce(xp)[0]
ekin[0]=v0**2*0.5
etot[0]= eptot[0]+ekin[0]

for i in range(0,len(positions)-1):
    enp,fc=calcforce(positions[i])
    #pdb.set_trace()
    eptot[i]=enp
    if i==0:
        newx,newtemp,newetot,newkin=integrate(positions[i],xp,fc,enp,dt)
    else:
        newx,newtemp,newetot,newkin=integrate(positions[i],positions[i-1],fc,enp,dt)
    positions[i+1]=newx
    ekin[i+1]=newkin
    etot[i+1]=newetot
    temp[i+1]=newtemp
    if np.mod(i,100):
        plt.clf()
        plt.subplot(221)
        plt.plot(base,0.5*(base-1)**2)
        plt.plot(newx,calcforce(newx)[0],'o',markersize=10)
        plt.xlabel('Position')
        plt.ylabel('Potential Energy')
        plt.subplot(222)
        plt.plot(eptot[1:i],'r',label='Ep')
        plt.plot(ekin[1:i],'b',label='Ek')
        plt.plot(etot[1:i],'g',label='Etot')
        plt.xlabel('Time')
        plt.ylabel('Energy')
        plt.ylim(0,etot[0]*1.1)
        plt.legend()
        plt.draw()
        plt.pause(.0001)
eptot[-1]=calcforce(positions[-1])[0]
