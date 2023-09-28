# FCC Tests

A bunch of FCC related tests.


## Where and when they run

Regularly at 7:00 AM on `fcc-ironic-02` machine. Time is selected to be after
nightlies key4hep stack is already build.


## Who gets the email

Everyone in the `emails.lst` file.


## Why Bash

Quick and dirty solution. Also, Bash is available on a lot of systems.


## To Do

* Report output logs somewhere
* Bash is just a quick hack
* Run this in Docker/Podman --- CC7, AlmaLinux9, RH9, Ubuntu
* Check if the nightlies stack is really build for the day and if not skip the
    tests for that day
* Benchmarks too?
