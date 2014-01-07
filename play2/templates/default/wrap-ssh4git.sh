#!/usr/bin/env bash
/usr/bin/env ssh -o "StrictHostKeyChecking=no" -i "<%= @private_key %>" $1 $2
