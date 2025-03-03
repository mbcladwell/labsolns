(define-module (labsolns triweb)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages linux)
;;  #:use-module (labsolns guile-oauth)
;;  #:use-module (labsolns artanis-122)
  #:use-module (json)

  )

(define-public triweb
             (let ((commit "0f610bd0f3cc230ab33982683cb4effa44a673f6")
        (revision "4"))
(package
  (name "triweb")
  (version (string-append "0.1." (string-take commit 7)))
  (source (origin
           (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/mbcladwell/triweb")
                      (commit commit)))
                        (file-name (git-file-name name version))
                (sha256 
             (base32 "0z730396nkvjhxdj9ndl31hgzmn8qxiaydg4b760214dvw5vc03k"))))
  (build-system guile-build-system)
  
  (native-inputs
    `(("guile" ,guile-3.0)))
  (propagated-inputs `(("bash" ,bash)("limsn" ,limsn)("conman" ,conmanv5)("babweb" ,babweb)))
  (synopsis "AWS setup providing limsn, artanis, babweb, and conman")
  (description "AWS setup providing limsn, artanis, babweb, and conman")
  (home-page "www.labsolns.com")
  (license license:gpl3+))))

(define-public artanis-122
  (package
    (name "artanis-122")
    (version "1.2.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/artanis/artanis-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "013rs623075bbf824hf6jxng0kwbmg587l45fis9mmpq5168kspq"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  (delete-file-recursively "artanis/third-party/json.scm")
                  (delete-file-recursively "artanis/third-party/redis.scm")
                  (substitute* '("artanis/artanis.scm"
                                 "artanis/lpc.scm"
                                 "artanis/i18n/json.scm"
                                 "artanis/oht.scm"
                                 "artanis/tpl/parser.scm")
                    (("(#:use-module \\()artanis third-party (json\\))" _
                      use-module json)
                     (string-append use-module json)))
                  (substitute* '("artanis/lpc.scm"
                                 "artanis/session.scm")
                    (("(#:use-module \\()artanis third-party (redis\\))" _
                      use-module redis)
                     (string-append use-module redis)))
                  (substitute* "artanis/oht.scm"
                    (("([[:punct:][:space:]]+)(->json-string)([[:punct:][:space:]]+)"
                      _ pre json-string post)
                     (string-append pre
                                    "scm" json-string
                                    post)))
		  ;;BEGIN LIMS*Nucleus modification;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		  (substitute* "artanis/config.scm"
		   	       (("debug.monitor = <PATHs>\")")
		   		"debug.monitor = <PATHs>\")\n\n ((cookie maxplates)\n       10\n      \"Maximum number of plates per plate-set.\n cookie.maxplates = <integer>\")\n")
			       (("    \\(else \\(error parse-namespace-cookie \"Config: Invalid item\" item\\)\\)\\)\\)")
		   		"    (('maxplates maxplates) (conf-set! '(cookie maxplates) (->integer maxplates)))\n    (else (error parse-namespace-cookie \"Config: Invalid item\" item))))"
				))
		  ;;END LIMS*Nucleus modification;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		  
                  (substitute* "artanis/artanis.scm"
                    (("[[:punct:][:space:]]+->json-string[[:punct:][:space:]]+")
                     ""))
                  #t))))
    (build-system gnu-build-system)
    (inputs
     (list bash-minimal guile-3.0 nspr nss))
    ;; FIXME the bundled csv contains one more exported procedure
    ;; (sxml->csv-string) than guile-csv. The author is maintainer of both
    ;; projects.
    ;; TODO: Add guile-dbi and guile-dbd optional dependencies.
    (propagated-inputs
     (list guile-json-4 guile-curl guile-readline guile-redis))
    (native-inputs
     (list bash-minimal                           ;for the `source' builtin
           pkg-config
           util-linux))                           ;for the `script' command
    (arguments
     `(#:modules (((guix build guile-build-system)
                   #:select (target-guile-effective-version))
                  ,@%default-gnu-modules)
       #:imported-modules ((guix build guile-build-system)
                           ,@%default-gnu-imported-modules)
       #:make-flags
       ;; TODO: The documentation must be built with the `docs' target.
       (let* ((out (assoc-ref %outputs "out"))
              ;; We pass guile explicitly here since this executes before the
              ;; set-paths phase and therefore guile is not yet in PATH.
              (effective-version (target-guile-effective-version
                                  (assoc-ref %build-inputs "guile")))
              (scm (string-append out "/share/guile/site/" effective-version))
              (go (string-append out "/lib/guile/" effective-version "/site-ccache")))
         ;; Don't use (%site-dir) for site paths.
         (list (string-append "MOD_PATH=" scm)
               (string-append "MOD_COMPILED_PATH=" go)))
       #:test-target "test"
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-site-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "artanis/commands/help.scm"
               (("\\(%site-dir\\)")
                (string-append "\""
                               (assoc-ref outputs "out")
                               "/share/guile/site/"
                               (target-guile-effective-version)
                               "\"")))))
         (add-after 'unpack 'patch-reference-to-libnss
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "artanis/security/nss.scm"
               (("ffi-binding \"libnss3\"")
                (string-append
                 "ffi-binding \""
                 (assoc-ref inputs "nss") "/lib/nss/libnss3.so"
                 "\""))
               (("ffi-binding \"libssl3\"")
                (string-append
                 "ffi-binding \"" (assoc-ref inputs "nss") "/lib/nss/libssl3.so\"")))))
         (add-before 'install 'substitute-root-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out  (assoc-ref outputs "out")))
               (substitute* "Makefile"   ;ignore the execution of bash.bashrc
                 ((" /etc/bash.bashrc") " /dev/null"))
               (substitute* "Makefile"   ;set the root of config files to OUT
                 ((" /etc") (string-append " " out "/etc")))
               (mkdir-p (string-append out "/bin")) )))
         (add-after 'install 'wrap-art
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (effective-version (target-guile-effective-version))
                    (bin (string-append out "/bin"))
                    (scm (string-append out "/share/guile/site/" effective-version))
                    (go (string-append out "/lib/guile/" effective-version
                                       "/site-ccache")))
               (wrap-program (string-append bin "/art")
                 `("GUILE_LOAD_PATH" ":" prefix
                   (,scm ,(getenv "GUILE_LOAD_PATH")))
                 `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                   (,go ,(getenv "GUILE_LOAD_COMPILED_PATH"))))))))))
    (synopsis "Web application framework written in Guile")
    (description "GNU Artanis is a web application framework written in Guile
Scheme.  A web application framework (WAF) is a software framework that is
designed to support the development of dynamic websites, web applications, web
services and web resources.  The framework aims to alleviate the overhead
associated with common activities performed in web development.  Artanis
provides several tools for web development: database access, templating
frameworks, session management, URL-remapping for RESTful, page caching, and
more. artanis-111 is based on artanis v1.1.0 and contains enhancements required
by LIMS*Nucleus.")
    (home-page "https://www.gnu.org/software/artanis/")
    (license (list license:gpl3+ license:lgpl3+)))) ;dual license



