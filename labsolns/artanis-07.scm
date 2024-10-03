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
;;  #:use-module (ice-9 readline)
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
             (let ((commit "0ef6dc04770ca5bd4c762d611c86a4cdaf7b2e77")
        (revision "4"))
  (package
    (name "artanis-07")
;;   (version (string-append "0.7." (string-take commit 7)))
   (version  (string-take commit 7))
    (source (origin
	     (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/mbcladwell/artanis")
                   (commit commit)))
             (file-name (git-file-name name version))
              (sha256
               (base32 "0jd0jh0jz2vfmxdzcpnmqa38lw9m0l3dyz1ynaw9d96xb5bzc1va"))
              (modules '((guix build utils)))

	      ))
    (build-system guile-build-system)
    (inputs
     (list bash-minimal guile-3.0 nspr nss))
    ;; FIXME the bundled csv contains one more exported procedure
    ;; (sxml->csv-string) than guile-csv. The author is maintainer of both
    ;; projects.
    ;; TODO: Add guile-dbi and guile-dbd optional dependencies.
    (propagated-inputs
     (list guile-json-4 guile-curl guile-readline))
    (native-inputs
     (list bash-minimal                           ;for the `source' builtin
       pkg-config
      guile-3.0                                   ;;required for guile-build-system see docs
           util-linux))                           ;for the `script' command
    (arguments
     `(
       ;; #:modules ((guix build guile-build-system)
       ;; 		  (guix build gnu-build-system)
       ;; ;;           ;;  #:select (target-guile-effective-version)
		   
       ;; 		   ;;            ,@%default-gnu-modules
       ;; 		   )
       ;; 		 #:imported-modules ((guix build guile-build-system)
       ;; 				     (guix build gnu-build-system)
       ;; 			    ;;                     ,@%default-gnu-imported-modules
       ;; 			    )
     
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-site-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "artanis/commands/help.scm"
               (("\\(%site-dir\\)")
                (string-append "\""
                               (assoc-ref outputs "out")
                               "/share/guile/site/3.0/"
                               "\"")))))
	 (add-after 'patch-site-dir 'modify-executable
	   (lambda* (#:key inputs outputs #:allow-other-keys)
	     (let ((out  (assoc-ref outputs "out")))					  
	       (substitute* '("./bin/art.in")
		 (("guileexecutable")
		  (string-append (assoc-ref inputs "guile") "/bin/guile"))) )
				    #t))		    	 	 
         (add-after 'modify-executable 'patch-reference-to-libnss
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
         (add-after 'patch-reference-to-libnss 'substitute-root-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out  (assoc-ref outputs "out"))
		   (bin-dir (string-append out "/bin"))
		   (_ (mkdir-p bin-dir))
                   )
	       (copy-recursively "./bin" bin-dir))))
         (add-after 'substitute-root-dir 'wrap-art
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (scm (string-append out "/share/guile/site/3.0/"))
                    (go (string-append out "/lib/guile/3.0/site-ccache")))
               (wrap-program (string-append bin "/art.in")
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
more.")
    (home-page "https://www.gnu.org/software/artanis/")
    (license (list license:gpl3+ license:lgpl3+))))) ;dual license

