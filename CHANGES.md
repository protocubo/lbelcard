# Changelog
_Summary of the changes in each version, from latest to earliest_

## Open-sourced: v1.3.0

26 March 2019.

Open-sourced (see #24).

 - Remove third-party copyrighted material
 - Replace old credentials with placeholders
 - Remove deprecated and outdated development script for Windows
 - **Add copyright disclaimer and license under AGPL v3+**
 - Fix build issues with latest development versions of Haxe v4
 - Automatically build on Travis CI with both Haxe stable and latest


## Long-term unassisted operation: v1.2.0

27 February 2018.

More features for long-term unassisted operation.

 - _Allow users to be refused at /novo with the 'disabled' metadata_
 - Add 2018 to the copyright notice
 - _Add /healtCheck API_
 - Simplify the output of trace location
 - Prefix all errors with ERR or greater, even if DispatchError
 - Notice requests as successful after sucess from `confirmar-pagamento`
 - Prefetch the ReCAPTCHA script on index
 - Fix extra word in /novo/confirma
 - Fix typo in /novo/status
 - Set X-Powered-By on responses
 - Set default content-type (html) and cache-control (never)
 - Set missing status=200 to some dev-only responses
 - Speed up font loading with preload and preconnect

This version ran without issues on L'BEL Card until 27 February 2019, when
requesting new cards was disabled.


## Patch release: v1.1.4

12 January 2018.

Prepare for long-term operation.

 - Fix: SendGridError should not count against user's request limit
 - Add specification for each CardRequestError
 - Optmize failsafe check for 1 card/user and count total cards as well
 - Increase maximum allowed queue size for long-term operation
 - Log belNumber when aborting due to invalid captcha
 - Disable requests by foreigners, AcessoCard can't handle them (see #16)
 - Simplify /novo/confirma display of documents' fields
 - Show informative error message for failed foreigners' requests (see #16)
 - Add SendGridError handling missing from /novo/status
 - Improve handling of card request not found/wrong state errors (see #12)
 - Set card request cookie to session and http only, but not secure
 - Add (experimental) priority log prefixes (both systemd and text variants)


## Patch release: v1.1.3

11 January 2018.

Critical fix.

 - Fix: AcessoPermanentError must not count against user's request limit

Also:

 - Allow Unserialize to read filenames, instead of just stdin/stdout


## Patch release: v1.1.2

9 January 2018.

 - Activate failsafe against requesting more than one card per user
 - Change the status page slightly: we usually recover from permanent errors

Also:

 - Allow Unserialize to read filenames, instead of just stdin/stdout


## Patch release: v1.1.1

9 January 2018.

Fix UF handling throughout the request form.

 - Trim off extra UF details returned by Correios (see #13)
 - Sort UFs alphabetically, not by population (see #14)
 - Set the first UFOrgao option based on the current address (see #14)
 - Change UFOrgao label, type and validation if document is not a RG (see #15)
 - Trace some data for missing cookie or invalid request state (see #12)


## Database reliability and data inspection improvements: v1.1.0

7 January 2018.

Minor upgrade to the v1.0.x series that records schema versions and saves
creation and last update timestamps for CardRequest and RemoteCallLog in the
DB.  In addition, this release also includes a few fixes, workarounds and UI
improvements.

 - _Add creation & last update timestamps to CardRequest (see #5)_
 - _Add creation timestamp to RemoteCallLog (see #5)_
 - _Add a Metadata table (see #5)_
 - _Add schema versionning and migration from implicit version 1_
 - _Check database integrity at module initialization_
 - Fix: resume and recover from jump-to-errors
 - Label code 20 replies from alterar-endereco-portador as user/data errors
 - **Hack: set payment as confirmed hours before to avoid bug at Acesso Card**
 - Prevent bad autocompletion (second iteration) (related to #6)
 - Hide the DDI field to solve 35% of user/data errors (see #9)
 - Fix rendered whitespace in /novo/confirma

Also:

 - Add support for CSV field filters to Unserialize
 - Add support for timestamp stringification to Unserilize


## Patch release: v1.0.3

4 January 2018.

Fixes after first day of heavy load.

 - Set SQLite busy_timeout to prevent SQLITE_BUSY errors (see #8)
 - Show AcessoUserOrDataError main messages if FieldErrors is absent or empty
 - Label code 2 replies from solicitar-adesao-cliente as user/data errors
 - Label code 4 replies from complementar-dados-principais as user/data errors
 - Label code 19 replies from alterar-endereco-portador as user/data errors
 - Add translation/improvement to address:number field error
 - Finish the fix for HEAD requests by patching eweb.Dispatch

Also:

 - Add offline Unserialize command line helper


## Patch release: v1.0.2

2 January 2018...  Happy new year!

Fix call parameter per request from Acesso Card.

 - Change payment confirmation type to embossing only


## Patch release: v1.0.1

28 December 2017.

Small fixes to improve both user and bot experiences.

 - Fix favicon manifest paths
 - Fix DENotFound errors for UptimeRobot: _add HEAD / route_
 - Fix autocomplete settings in the main form (closes #6)
 - Set autofocus on /novo and /novo/dados to first input field


## Release to the general public: v1.0.0

20 December 2017.

Fully functional server, open to the general public.

This release includes many fixes and improvements over the initial v1.0.0-rc1,
including adaptive rate limiting since there will be no throttling of
invitations.

 - Fix tabindices for /novo, /novo/dados and /novo/confirma
 - Fix bottom padding for main content


## Third release candidate: v1.0.0-rc3

20 December 2017.

 - Log the human-attributed system version during init
 - Prevent accidental double request confirmation (closes #4)
 - Add failsafe against going over the card limit per user (related to #4)
 - _Rename L'BELcard to L'BEL Card_
 - _Refuse to authorize users if the queue is already too long_
 - _Add text to the status page for context_
 - Fix missing HTML5 DOCTYPE declaration
 - Fix footer links
 - _Add phone numbers to the footer_
 - _Make styling and content changes requested by BELCORP's marketing department_


## Second release candidate: v1.0.0-rc2

19 December 2017.

 - Fix typo in the main form
 - Add server version to the User-Agent string
 - Don't re-enqueue AcessoUserOrDataError
 - Log queue size on dequeue
 - Reduce forced stalls to prevent rate limits
 - Reduce the sleep time in the handler loop
 - Add failsafe to prevent accidental card fabrication during local builds
 - Trace the user number when starting a new card request
 - Fix storage of remote call timings (see #3)
 - Fix warning asserts on queued vs. state
 - Do not discard a module after a dispatch error
 - Add empty robots.txt
 - Fix datestring conversion into timestamps and SerializedDate
 - Count Failed states other than user error towards the request limit
 - _Change favicon to L'_


## First release candidate: v1.0.0-rc1

12 December 2017.

Fully functional server.

 - Fix #1: call update() after setting the last (successful) state

