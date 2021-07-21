## R Short Course

This repo contains files for a series of workshops titled, "R Short Course".
These workshops follow a hybrid format: a week before the scheduled meeting
time participants will be given access to pre-recorded content and recommended
readings to review at their own pace.  The following week, we’ll meet at the posted
time for 90 minutes over Zoom to answer questions and work on a collection of exercises.
At the end of the course, we’ll gather for a 3-hour practicum, in which we’ll
program a console version of the game “Mastermind”.

Pre-recorded video discussions are distributed via YouTube.  These videos are
only available to the University of Michigan community, meaning you need to be
logged into your @umich.edu email address in the browswer you are viewing them in.

## Links to Exercises

+ [Part 1](./exercises/part1/)

## Week 1 - Getting Started

In part 1, we’ll discuss the following topics:  
  + creation and naming of objects,
  + R’s global environment,
  + arithmetic operations,
  + R’s package system, and
  + reading and writing data.

### Recommended reading

In addition to the notes linked below under *Workshop Content*, I'd recommend
reading the following chapters from Hadley Wickham's
[R for Data Science](https://r4ds.had.co.nz/):
  + [Introduction](https://r4ds.had.co.nz/introduction.html)
  + [Workflow: basics](https://r4ds.had.co.nz/workflow-basics.html)
  + [Workflow: scripts](https://r4ds.had.co.nz/workflow-scripts.html)

If you are new to programming, you may also find these chapters from
Garrett Grolemund's [Hands on Programming with R](https://rstudio-education.github.io/hopr/)
helpful:  
  + Part 1, Chapters 1-3
  + Appendices, A-D. 

Finally, new and experienced programmers alike benefit from following style guidelines
to write readable, literate, code. I recommend the [tidyverse style guide](https://style.tidyverse.org/).
For part 1, I'd suggest reading:
  + "Welcome"
  + Section 1, "Files"
  + Section 2, excluding 2.3 (function calls) and 2.4 (control flow) which fit better with future parts.

### Workshop content

The notes for this week can be found at
[R Short Course, Part 1](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html).
The links below point to specific sections of these notes.

You can use the links below to download the example scripts used in the videos.
These can also be found [here](https://github.com/jbhender/CSCAR_Workshops/tree/main/rsc/examples/part1). 

The video recordings are also collected in a playlist
[R Short Course: Part 1](https://youtube.com/playlist?list=PLa-LAe1K0RROENlYTphgqPyko29cTk3e4). 

+ Creation and Naming of Objects:  
   - [Notes](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html#basics)
   - Example Script: [R_basics.R](./examples/part1/R_basics.R)
   - [Video Lecture](https://youtu.be/izjtF3DcVZg)
     + The section "Value vs Reference" [9:36-12:35] is not essential material for
       new programmers. 

+ R's Global Environment:  
   - [Notes](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html#global_environment)
   - Example Script: [R_basics.R](./examples/part1/R_basics.R)
   - [Video Lecture](https://youtu.be/RyrNQ4sjDUg)
     + The section "programmatic assignment" [6:01-16:17] is not essential to get the most
       out of the remainder of the course. 

+ Arithmetic Operations:  
   - [Notes](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html#arithmetic)
   - Example Script: [R_arithmetic.R](./examples/part1/R_arithmetic.R)
   - [Video Lecture](https://youtu.be/mZup0mEK8X8)

+ R's Package System:  
   - [Notes](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html#paackages)
   - Example Script: [R_packages.R](./examples/part1/R_packages.R)
   - [Video Lecture](https://youtu.be/MuFKwpguDEs)

+ Reading and Writing Data:
   - [Notes](https://jbhender.github.io/workshops/rsc/R_Short_Course_Part1.html#io)
   - Example Script: [R_IO.R](./examples/part1/R_IO.R)
   - [Video Lecture](https://youtu.be/6et6TabZQf8)
     + The sections "reading and writing data with tidyverse" [5:52-8:06] and
       "reading and writing data with data.table" [8:06-9:35] can be skipped if desired.
     + The sections "serialized R data" [13:41-15:48] and
       "reading data from other software" [15:48-17:50] are not essential to the remainder
       of the short course.

