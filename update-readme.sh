#!/bin/bash

tree -v -L 3 | awk 'BEGIN{print "```bash"} {print} END{print "```"}' > README.md
