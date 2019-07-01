#!/bin/bash

tree -v | awk 'BEGIN{print "```bash"} {print} END{print "```"}' > README.md
