#!/usr/bin/env python
# coding: utf-8

# In[1]:


import sys

if len(sys.argv) != 5:
    print("Please give the redu-state-energy-sol oxid-state-energy-sol num-electron (unit Hatree)")
    print("Example: python redox_potential.py -50.0 -50.5 -70.0 -70.6 2")
    exit()


# dG = G_sol_oxid - G_sol_redu - 2.5*nRT
# fomula = dG / nF - 4.67


# Define const.
faraday = 23.061 #(kcal/mol)
shift_const = 4.67


# Hatree to kcal/mol
def HartreeToKcalMol(Hartree):
    return Hartree*627.51

# Pre-transform
energys = [map(HartreeToKcalMol, [map(float, sys.argv[1:3])])]
num_transfer = int(sys.argv[3])
thermal_energy = 2.5 * 1.9872036 * 298 / 1000

# Calculate
dG = energys[1] - energys[0] - num_transfer * thermal_energy
std_potential = dG / num_transfer / faraday - shift_const

print("delta-G =", dG)
print("standard potential =", std_potential)