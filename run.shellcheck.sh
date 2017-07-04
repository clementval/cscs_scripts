#!/bin/bash

# ECMWFC scripts
shellcheck ecmwf/offline.claw_install.step1_ecgate.sh
shellcheck ecmwf/offline.claw_install.step2_lxg.sh

# CSCS scripts
shellcheck cscs/install.ant.sh
shellcheck cscs/jenkins.install-ant.sh
shellcheck cscs/jenkins.claw.sh
shellcheck cscs/jenkins.omni-parse.sh
shellcheck cscs/jenkins.omni.sh
shellcheck cscs/test.claw.sh
