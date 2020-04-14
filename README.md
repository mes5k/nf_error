
# Introduction

This project demonstrates one way of handling errors in [Nextflow](https://nextflow.io) such that errors themselves become values in the pipeline.  Instead of handling errors outside the logic of the pipeline, this allows us to use the error data within the pipeline.  The use case is a pipeline that generates a report based on N input samples. If processing of a sample fails, the report must note that failure so that all N samples are accounted for in the final report.

## Code

This approach uses an `afterScript` which checks the error status of the process `script` and if it fails, writes a file containing error data.

To get the errors into the pipeline as channels, the error file is emitted as an _optional_ channel. When errors occur, the normal output won't exist, so those channels must also be made _optional_.

## Problems

There are several problems with this approach:
1. First and most serious, I've not found a way to get process `input` information into the error output file. Without knowing which input data fails makes the error almost useless. The best I'm able to do is identify the process name and it's current directory. None of the `val`s or `path`s that might be in the `input` seem to be available to the `after.sh` script.
1. Second and nearly as serious, the after script uses internal values from the `.command.run` script that Nextflow generates. These values are surely not intended to be public and used in the manner in which they are. Things are almost certain to break when `.command.run` changes.
1. All output channels now need to be optional. This adds a lot of boilerplate to the code and makes handling the output channels a bit more complicated in the workflow. Likewise, specifying an afterscript for each process is just more boilerplate.

# Summary

The approach generated here isn't really recommended. A more complicated wrapper script would be needed to address the problem of inadequate information in the error output. That also complicates `process` writing and likely adds even more boilerplate.

Ideally there would be a native `errorStrategy` for generating some sort of error data structure of file when a process fails.
