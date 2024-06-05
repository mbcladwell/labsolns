(define-module (labsolns artanis-07)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages guile)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (json)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages linux)
;;   #:use-module (ice-9 readline)
   #:use-module (gnu packages nss) ;;;;;;;;;;
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages hurd)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages mes)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages noweb)
   #:use-module (gnu packages package-management)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages tls)
   #:use-module (gnu packages version-control)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix modules)
  #:use-module (guix monads)
   #:use-module (guix i18n)
  #:use-module (guix records)
  #:use-module (guix search-paths)
   #:use-module (guix derivations)
  #:use-module (guix store)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix utils)
  #:autoload   (srfi srfi-98) (get-environment-variables)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (ice-9 match)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages search)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages slang)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xorg)
  #:use-module ((srfi srfi-1) #:select (alist-delete))

  )

(define-public artanis-07
             (let ((commit "69de573cffe92c95892bf997978ad99dc6b42493")
        (revision "4"))
  (package
    (name "artanis")
    (version (string-append "0.7." (string-take commit 7)))
    (source (origin
	     (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/mbcladwell/artanis")
                   (commit commit)))
             (file-name (git-file-name name version))
              (sha256
               (base32 "15b860kmgabbdha2mjd7dlqn6csklwwbjhhc1qv6mscqfgi334a1"))
              (modules '((guix build utils)))

	      ))
    (build-system guile-build-system)
    (inputs
     (list guile-3.0 nspr nss))
    ;; FIXME the bundled csv contains one more exported procedure
    ;; (sxml->csv-string) than guile-csv. The author is maintainer of both
    ;; projects.
    ;; TODO: Add guile-dbi and guile-dbd optional dependencies.
      (propagated-inputs
     (list guile-json-4 guile-curl guile-readline))
    (native-inputs
     (list bash-minimal                           ;for the `source' builtin
           pkg-config
           util-linux))                           ;for the `script' command
  
    (arguments
     '(
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-site-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "artanis/commands/help.scm"
               (("\\(%site-dir\\)")
                (string-append "\""
                               (assoc-ref outputs "out")
                               "/share/guile/site/3.0\"")))))
         (add-after 'unpack 'patch-reference-to-libnss
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "artanis/security/nss.scm"
               (("ffi-binding \"libnss3\"")
                (string-append
                 "ffi-binding \""
                 (assoc-ref inputs "nss") "/lib/nss/libnss3.so" ;;/lib/nss in original
		 "\""))
               (("ffi-binding \"libssl3\"")
                (string-append "ffi-binding \""
			       (assoc-ref inputs "nss") "/lib/nss/libssl3.so"  ;; /lib/nss in original
                 "\"")))
             #t))
	 (add-after 'unpack 'modify_executable
	   (lambda* (#:key inputs outputs #:allow-other-keys)
	     (let ((out  (assoc-ref outputs "out")))					  
	       (substitute* '("./bin/art.in")
		 (("guileexecutable")
		  (string-append (assoc-ref inputs "guile") "/bin/guile"))) )
				    #t))		    	 

         (add-before 'install 'substitute-root-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out  (assoc-ref outputs "out"))
		   (bin-dir (string-append out "/bin"))
		   (dummy (mkdir-p bin-dir))
		   )
                  (copy-recursively "./bin" bin-dir) ;for the `art' executable
		  #t)))	 
         (add-after 'install 'wrap-art
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (scm (string-append out "/share/guile/site/3.0"))
                    (go  (string-append out "/lib/guile/3.0/site-ccache")))
               (wrap-program (string-append bin "/art.in")
                 `("GUILE_LOAD_PATH" ":" prefix
                   (,scm ,(getenv "GUILE_LOAD_PATH")))
                 `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                   (,go ,(getenv "GUILE_LOAD_COMPILED_PATH"))))
               #t))))))
    (synopsis "Web application framework written in Guile, modified for LIMS*Nucleus")
    (description "GNU Artanis is a web application framework written in Guile
Scheme.  A web application framework (WAF) is a software framework that is
designed to support the development of dynamic websites, web applications, web
services and web resources.  The framework aims to alleviate the overhead
associated with common activities performed in web development.  Artanis
provides several tools for web development: database access, templating
frameworks, session management, URL-remapping for RESTful, page caching, and
more. v0.6 contains feature enhancements required by LIMS*Nucleus. v0.6 install
uses Guile Build System; v0.7 is used by build-a-bot")
    (home-page "https://www.gnu.org/software/artanis/")
    (license (list license:gpl3+ license:lgpl3+))))) ;dual license

