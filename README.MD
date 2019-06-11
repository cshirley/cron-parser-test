# Technical Task - Cron Expression Parser

Write a command line application or script which parses a cron string and expands each field to show the times at which it will run. You may use any of the following languages: Ruby, Scala, JavaScript, Python, Go, Java, or C# (using .NET Core as we need it to run on OS X/Linux).

You should only consider the standard cron format with five time fields (minute, hour, day of month, month, and day of week) plus a command; you do not need to handle the special time strings such as "@yearly".

The cron string will be passed to your application on the command line as a single argument on a single line. For example:

`~$ your-program */15 0 1,15 * 1-5 /usr/bin/find`

Or:

`~$ application-commands file-name -arguments */15 0 1,15 * 1-5 /usr/bin/find`

The output should be formatted as a table with the field name taking the first 14 columns and the times as a space-separated list following it.

## Install

`bundle install`

## Usage

`./bin/cron-parser 1 1 1 1 1 /usr/bin/find`

## Tests

` rspec `

### COVERAGE:  92.23% -- 95/103 lines in 4 files

Ran out of time

coverage | File | Lines | Missed | Missing |
--- | --- | --- | --- | ---
58.33% | lib/client.rb | 12 | 5 | 10-11, 20, 22, 24
75.00% | lib/cron/formatter.rb | 12 | 3 | 22-23, 29

## TODO

- specs for lib/cron/formatter.rb, lib/client.rb
- refactor lib/cron/parser.rb to use strategy pattern for building ranges
- RDOCs

## Bugs

- cron-parser is globbing with passing wild cards therefor we have escape wildcards at the moment
- the second command line format is not supported
