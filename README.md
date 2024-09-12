## Description

`working_on` is a really simple CLI to track your time on various projects. 

## Usage

### Start a Project

`working_on <project>`

Will start a new session for the specified project. If a session is running for another project that timer will be stopped and the time you spent on that project will be logged.

**Example**
`working_on "CLI to track my project time"`

### Add notes

`working_on --note "This is my note"`

Will log the note under the active session.

### Log Off

`working_on --logoff`

Will end your current session without starting a new one.

### File Location

The file is located @ `~/.working_on.json`

## Installation

```
git clone git@github.com:RichardBlair/working_on.git
cd working_on
gem build working_on.gemspec
gem install ./working_on-0.1.0.gem
```

Replace `0.1.0` in the `gem install` step with the current version.
