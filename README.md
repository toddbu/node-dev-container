# Node Dev Container

## About This Project

I have long been a believer that it is best to develop software in an envrionment as close to your production settings as possible. So when I first started working with Docker containers in 2015, it seemed natural to have a development environment that ran inside of a Docker container. Thus began my work on the `node-dev-container` project. While the Docker container image produced by this repo is suitable for development in the Node language (Javascript) running under Ubuntu, it can often be readily adapted to other programming languages and Linux distros. Since most Linux distros use Python for their core functionality, Python works pretty well without any modifications. I have adapted this same technology to support such combinations as `dotnetcore` running under CentOS, so there is a lot of flexibility in how you use this.

## Design Philosophy

Since production environments typcially only contain running code and not things like IDEs, this project is designed in such a way that UI tools run outside of the container while the container itself allows those UIs to interact with the container. So what does this mean in practice? Let me tell you about my current setup to give you just one possible example of how this container image may be used...

I've been a a Linux guy since 2001 and a Mac guy since 2011. I develop Node code in Ubuntu. I try to keep up with the latest LTS version of everything. I code in both Sublime Text on the Mac and `vi` on Ubuntu. My repos are all in `git`. Depending on which Mac laptop I'm on, my containers are running in either VirtualBox (Intel Mac) or Docker Desktop (M1 Mac). No matter which laptop I'm on, I have a consistent, seamless experience.

## Implementation Details

So how is it that all of this can work so smoothly? The key is running the dev container inside of a virtual machine (VM) on your laptop. Combine this with a little port forwarding magic and you're good to go. It really is just that easy.

Communication between the laptop and the dev container occurs in one of three ways:

* SSH - SSH is an amazing tool that allows you to connect to the container and do any command line stuff that you want. It's perfect for people like me who spend most of their time in a terminal session. (Side note - if you're not already using iTerm2 on your Mac then you really should check it out)

* SFTP - Some editors like Atom allow you to edit files directly on remote directories using SFTP. Or maybe you need to transfer files between your laptop and your container. SFTP is great for this

* SMB / AFP - If you want to use just a regular old file shares then SMB and AFP work well. If you're running a Windows laptop then SMB may be best for you. I use AFP on my Mac since it is more routeable

Since you need to get network traffic routed between your laptop and your container and there is a VM in between them (even using Docker Desktop), you have a few options on how to do this:

* Set up a NAT network (private network) and then select the ports that you want to forward from the laptop to the container. This works well if you have no port conflicts, and is generally how I have my environemnt set up

* Set up a bridged network (public network) so that your VM gets an IP address separate from your laptop. This is the best option for Docker Desktop, although as you'll see below this functionality is broken as of 8/20/22 and requires a workaround

## Installation

How you install this container depends on whether you intend to run on a VM that you manage like VirtualBox or if you'll be using Docker Desktop. Both start with the same set of instructions but diverge when you build and start them:

* VirtualBox and other VM Providers
    * Create a new **server** VM from Ubuntu or your distro of choice. I recommend installing a "minimal" installation if avaiable, then adding Docker as the only package. Remember to enable Docker on startup by doing a `systemctl enable docker` so that Docker starts immediately on boot. The username and password for the new VM are for you to pick
    * Log into your VM
    * Clone the git repo at https://github.com/toddbu/node-dev-container
    * `cd node-dev-container`
    * `./build`
    * `./start`    
* Docker Desktop
    * Install Docker Desktop from https://www.docker.com/products/docker-desktop/
    * Install Vagrant from https://www.vagrantup.com/
    * Clone the git repo at https://github.com/toddbu/node-dev-container
    * `cd node-dev-container`
    * `./build`
    * `vagrant up`

Once your dev container is running, please note the following:

  + You should now be able to connect to your container via SSH at port 2222 (`-p 2222`). The username is `dev` and the password is `dev123!`. If you're running your network in NAT mode then the hostname to connect to is `localhost`. Otherwise, use the bridged IP address that you selected when you set up the VM
  + If you want to use AFP, login as the `dev` user (above)
  + If you want to use SMB, the username is `dev` and the password is `sambapwd`

## Docker Desktop and Public Networks

As of this writing, there is a bug in the Docker Desktop software on Macs that prevents you from properly creating a bridged IP (https://github.com/docker/for-mac/issues/3926), so I've had to come up with a workaround. If you create your container with a NATted IP, then you can manually build a tunnel between your container and your laptop for the ports that you want to forward. Simply SSH into the container and type `ssh toddbu@<your laptop IP> -R 2548:localhost:548` if you want to use AFP. Then your Mac, type Command-K from the Finder and use `afp://localhost:2548` as the connection address. Before you connect your probably want to enter the following into your `~/.ssh/config` file to prevent your SSH connection from timing out - `ServerAliveInterval 30`

### License

This software is licensed under the MIT license, which reads...

```
Copyright (c) 2019 Todd Buiten

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```