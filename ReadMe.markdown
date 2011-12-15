Read Me About ECHelper
======================

This is based on apple's SMJobBless example, which shows how to cleanly install a helper tool that needs to run with privileges as a launchd task.

The original SMJobBless documentation is available from http://developer.apple.com/library/mac/#samplecode/SMJobBless/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010071-Intro-DontLinkElementID_2

The biggest problem with this task is that the helper tool and the host application that's going to install it have to be set up very carefully to have the right code-signing details and bundle ids.

If you wanted to change these in the SMJobBless example you had to do it in lots of different places - and it was easy to miss one.

This sample gets round that problem by setting three user-defined values at the project level:


    HELPER_ID = com.elegantchaos.helper.helper
    HOST_ID = com.elegantchaos.helper.host
    HELPER_SIGNING = 3rd Party Mac Developer Application: Sam Deane


You should set HELPER_ID to the bundle id that you want to use for your helper application.

You should set HOST_ID to the bundle id that you want to use for the host application - the one that installs the helper (and which probably makes use of it, although that's not necessarily the case).

You should set HELPER_SIGNING to the code signing profile that you want to use to sign everything. Note that if this profile is associated with a bundle id pattern (eg. com.elegantchaos.*) then the HELPER_ID and HOST_ID settings must match the pattern, otherwise xcode will refuse to sign the applications.