 
  (define-module (labsolns limsn)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages hurd)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mes)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages noweb)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages search)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages slang)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module (guix utils)
  #:use-module ((guix build utils) #:select (alist-replace))
  #:use-module (ice-9 match)
  #:use-module (labsolns artanis-07)
 ; #:use-module (artanis utils)
 ; #:use-module (artanis irregex)
 ; #:use-module (artanis config)  
;;  #:use-module (dbi dbi)    
  #:use-module ((srfi srfi-1) #:select (alist-delete)))

(define-public limsn
             (let ((commit "5b77d07c73476ef070876f38638bd7447dd3fd40")
        (revision "2"))

  (package
    (name "limsn")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
           (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/mbcladwell/limsn")
                      (commit commit)))
                        (file-name (git-file-name name version))
                (sha256 
             (base32 "0il6fbgaf0yzj8gc1dhnyk4xf0nchgyn8yphvdfb3qk3vgilhk0h"))))
  
   
   (build-system guile-build-system)
  (arguments `(
			#:phases (modify-phases %standard-phases
    		       (add-after 'unpack 'patch-prefix
			       (lambda* (#:key inputs outputs #:allow-other-keys)
				 (substitute* '("./limsn/lib/labsolns/lnpg.scm"
						"./scripts/start-limsn.sh"
						"./scripts/init-ln.sh"
						"./limsn/ENTRY")						
						(("abcdefgh")
						(assoc-ref outputs "out" )) )
				 #t))		       			       
		(add-after 'unpack 'augment-GUILE_LOAD_PATH
			   (lambda _
			     (setenv "GUILE_LOAD_PATH"
				     (string-append "./limsn/lib:"
						    (getenv "GUILE_LOAD_PATH")))
			     #t))
                       (add-after 'unpack 'make-lib-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (lib-dir (string-append out "/share/guile/site/3.0/limsn/lib"))
					   (dummy (mkdir-p lib-dir)))            				       
				       (copy-recursively "./limsn/lib" lib-dir)
				       #t)))
		       (add-after 'make-lib-dir 'make-dir
				   (lambda* (#:key outputs #:allow-other-keys)
				     (let* ((out  (assoc-ref outputs "out"))
					   (labsolns-dir (string-append out "/labsolns"))
					   (mkdir-p labsolns-dir)
					   (dummy (copy-recursively "./limsn/lib/labsolns" labsolns-dir))) 
				       #t)))

                       (add-after 'make-dir 'make-scripts-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/share/guile/site/3.0/limsn/scripts"))
					;;   (scripts-dir (string-append out "/scripts"))
					   (dummy (mkdir-p scripts-dir)))            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t)))
		       (add-after 'make-scripts-dir 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/share/guile/site/3.0/limsn/bin"))
					   (dummy (install-file "limsn/bin/start-limsn.sh" bin-dir))				
					   (dummy (chmod (string-append bin-dir "/start-limsn.sh") #o555 ))) ;;read execute, no write
				      (wrap-program (string-append bin-dir "/start-limsn.sh")
						    `( "PATH" ":" prefix  (,bin-dir) ))		    
				      #t)))				      				     				      			    		 		             
		       )))
    (inputs
     `(("guile" ,guile-3.0)
       ("gnuplot" ,gnuplot)
       ("guile-dbi" ,guile-dbi)
       ))
    (propagated-inputs
     `(
       ("artanis" ,artanis-07)
       ))
    (native-inputs
     `(("bash"       ,bash)         ;for the `source' builtin
     ;;  ("pkgconfig"  ,pkg-config)
     ;;  ("autoconf" ,autoconf)
     ;;  ("automake" ,automake)
    ;;   ("texinfo" ,texinfo)
       ("util-linux" ,util-linux))) ;for the `script' command

    (synopsis "Microwell Plate management Software")
    (description "description")
    (home-page "http://www.labsolns.com/")
    (license (list license:gpl3+ license:lgpl3+))))) ;dual license


;; (define-public artanis-07
;;             (let ((commit "5b77d07c73476ef070876f38638bd7447dd3fd40")
;;         (revision "4"))
;;   (package
;;     (name "artanis-07")
;; ;;   (version (string-append "0.7." (string-take commit 7)))
;;    (version  (string-take commit 7))
;;     (source (origin
;; 	     (method git-fetch)
;;              (uri (git-reference
;;                    (url "https://github.com/mbcladwell/artanis")
;;                    (commit commit)))
;;              (file-name (git-file-name name version))
;;               (sha256
;;                (base32 "0jd0jh0jz2vfmxdzcpnmqa38lw9m0l3dyz1ynaw9d96xb5bzc1va"))
;;               (modules '((guix build utils)))

;; 	      ))
;;     (build-system guile-build-system)
;;     (inputs (list bash-minimal guile-3.0 nss nspr
;; 	   ))
;;     ;; FIXME the bundled csv contains one more exported procedure
;;     ;; (sxml->csv-string) than guile-csv. The author is maintainer of both
;;     ;; projects.
;;     ;; TODO: Add guile-dbi and guile-dbd optional dependencies.
;;     (propagated-inputs
;;      (list guile-json-4 guile-curl guile-readline))
;;     (native-inputs
;;      (list bash-minimal                           ;for the `source' builtin
;;        pkg-config
;;       guile-3.0                                   ;;required for guile-build-system see docs
;;            util-linux))                           ;for the `script' command
;;     (arguments
;;      `(
;;        ;; #:modules ((guix build guile-build-system)
;;        ;; 		  (guix build gnu-build-system)
;;        ;; ;;           ;;  #:select (target-guile-effective-version)
		   
;;        ;; 		   ;;            ,@%default-gnu-modules
;;        ;; 		   )
;;        ;; 		 #:imported-modules ((guix build guile-build-system)
;;        ;; 				     (guix build gnu-build-system)
;;        ;; 			    ;;                     ,@%default-gnu-imported-modules
;;        ;; 			    )
     
;;        #:phases
;;        (modify-phases %standard-phases
;;          (add-after 'unpack 'patch-site-dir
;;            (lambda* (#:key outputs #:allow-other-keys)
;;              (substitute* "artanis/commands/help.scm"
;;                (("\\(%site-dir\\)")
;;                 (string-append "\""
;;                                (assoc-ref outputs "out")
;;                                "/share/guile/site/3.0/"
;;                                "\"")))))
;; 	 (add-after 'patch-site-dir 'modify-executable
;; 	   (lambda* (#:key inputs outputs #:allow-other-keys)
;; 	     (let ((out  (assoc-ref outputs "out")))					  
;; 	       (substitute* '("./bin/art.in")
;; 		 (("guileexecutable")
;; 		  (string-append (assoc-ref inputs "guile") "/bin/guile"))) )
;; 				    #t))		    	 	 
;;          (add-after 'modify-executable 'patch-reference-to-libnss
;;            (lambda* (#:key inputs #:allow-other-keys)
;;              (substitute* "artanis/security/nss.scm"
;;                (("ffi-binding \"libnss3\"")
;;                 (string-append
;;                  "ffi-binding \""
;;                  (assoc-ref inputs "nss") "/lib/nss/libnss3.so"
;;                  "\""))
;;                (("ffi-binding \"libssl3\"")
;;                 (string-append
;;                  "ffi-binding \"" (assoc-ref inputs "nss") "/lib/nss/libssl3.so\"")))))
;;          (add-after 'patch-reference-to-libnss 'substitute-root-dir
;;            (lambda* (#:key outputs #:allow-other-keys)
;;              (let* ((out  (assoc-ref outputs "out"))
;; 		   (bin-dir (string-append out "/bin"))
;; 		   (_ (mkdir-p bin-dir))
;;                    )
;; 	       (copy-recursively "./bin" bin-dir))))
;;          (add-after 'substitute-root-dir 'wrap-art
;;            (lambda* (#:key inputs outputs #:allow-other-keys)
;;              (let* ((out (assoc-ref outputs "out"))
;;                     (bin (string-append out "/bin"))
;;                     (scm (string-append out "/share/guile/site/3.0/"))
;;                     (go (string-append out "/lib/guile/3.0/site-ccache")))
;;                (wrap-program (string-append bin "/art.in")
;;                  `("GUILE_LOAD_PATH" ":" prefix
;;                    (,scm ,(getenv "GUILE_LOAD_PATH")))
;;                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
;;                    (,go ,(getenv "GUILE_LOAD_COMPILED_PATH"))))))))))
;;     (synopsis "Web application framework written in Guile")
;;     (description "GNU Artanis is a web application framework written in Guile
;; Scheme.  A web application framework (WAF) is a software framework that is
;; designed to support the development of dynamic websites, web applications, web
;; services and web resources.  The framework aims to alleviate the overhead
;; associated with common activities performed in web development.  Artanis
;; provides several tools for web development: database access, templating
;; frameworks, session management, URL-remapping for RESTful, page caching, and
;; more.")
;;     (home-page "https://www.gnu.org/software/artanis/")
;;     (license (list license:gpl3+ license:lgpl3+))))) ;dual license


;; (define-public guile-curl
;;   (package
;;    (name "guile-curl")
;;    (version "0.9")
;;    (source (origin
;;             (method url-fetch)
;;             (uri (string-append "http://www.lonelycactus.com/tarball/"
;;                                 "guile_curl-" version ".tar.gz"))
;;             (sha256
;;              (base32
;;               "0y7wfhilfm6vzs0wyifrrc2pj9nsxfas905c7qa5cw4i6s74ypmi"))))
;;    (build-system gnu-build-system)
;;    (arguments
;;     `(#:modules (((guix build guile-build-system)
;;                   #:select (target-guile-effective-version))
;;                  ,@%default-gnu-modules)
;;       #:imported-modules ((guix build guile-build-system)
;;                           ,@%default-gnu-imported-modules)
;;       #:configure-flags (list (string-append
;;                                "--with-guilesitedir="
;;                                (assoc-ref %outputs "out")
;;                                "/share/guile/site/"
;;                                (target-guile-effective-version
;;                                 (assoc-ref %build-inputs "guile")))
;;                               (string-append
;;                                "-with-guileextensiondir="
;;                                (assoc-ref %outputs "out")
;;                                "/lib/guile/"
;;                                (target-guile-effective-version
;;                                 (assoc-ref %build-inputs "guile"))
;;                                "/extensions"))
;;       #:phases
;;       (modify-phases %standard-phases
;;         (add-after 'unpack 'patch-undefined-references
;;           (lambda* _
;;             (substitute* "module/curl.scm"
;;               ;; The following #defines are missing from our curl package
;;               ;; and therefore result in the evaluation of undefined symbols.
;;               ((",CURLOPT_HAPROXYPROTOCOL") "#f")
;;               ((",CURLOPT_DISALLOW_USERNAME_IN_URL") "#f")
;;               ((",CURLOPT_TIMEVALUE_LARGE") "#f")
;;               ((",CURLOPT_DNS_SHUFFLE_ADDRESSES") "#f")
;;               ((",CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS") "#f"))))
;;         (add-after 'install 'patch-extension-path
;;           (lambda* (#:key outputs #:allow-other-keys)
;;             (let* ((out      (assoc-ref outputs "out"))
;;                    (curl.scm (string-append
;;                               out "/share/guile/site/"
;;                               (target-guile-effective-version)
;;                               "/curl.scm"))
;;                    (curl.go  (string-append
;;                               out "/lib/guile/"
;;                               (target-guile-effective-version)
;;                               "/site-ccache/curl.go"))
;;                    (ext      (string-append out "/lib/guile/"
;;                                             (target-guile-effective-version)
;;                                             "/extensions/libguile-curl")))
;;               (substitute* curl.scm (("libguile-curl") ext))
;;               ;; The build system does not actually compile the Scheme module.
;;               ;; So we can compile it and put it in the right place in one go.
;;               (invoke "guild" "compile" curl.scm "-o" curl.go)))))))
;;    (native-inputs (list pkg-config))
;;    (inputs
;;     (list curl guile-3.0))
;;    (home-page "http://www.lonelycactus.com/guile-curl.html")
;;    (synopsis "Curl bindings for Guile")
;;    (description "@code{guile-curl} is a project that has procedures that allow
;; Guile to do client-side URL transfers, like requesting documents from HTTP or
;; FTP servers.  It is based on the curl library.")
;;    (license license:gpl3+)))
