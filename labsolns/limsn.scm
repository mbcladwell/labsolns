 
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
 ; #:use-module (artanis artanis)
 ; #:use-module (artanis utils)
 ; #:use-module (artanis irregex)
 ; #:use-module (artanis config)  
  #:use-module (dbi dbi)    
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
  (arguments `(#:tests? #false ; there are none
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
                       (add-before 'install 'make-lib-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (lib-dir (string-append out "/share/guile/site/3.0/limsn/lib"))
					   (dummy (mkdir-p lib-dir)))            				       
				       (copy-recursively "./limsn/lib" lib-dir)
				       #t)))
		       (add-after 'unpack 'make-dir
				   (lambda* (#:key outputs #:allow-other-keys)
				     (let* ((out  (assoc-ref outputs "out"))
					   (labsolns-dir (string-append out "/labsolns"))
					   (mkdir-p labsolns-dir)
					   (dummy (copy-recursively "./limsn/lib/labsolns" labsolns-dir))) 
				       #t)))

                       (add-before 'install 'make-scripts-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/share/guile/site/3.0/limsn/scripts"))
					;;   (scripts-dir (string-append out "/scripts"))
					   (dummy (mkdir-p scripts-dir)))            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t)))
		       (add-after 'install 'make-bin-dir
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
    (license (list license:gpl3+ license:lgpl3+))) ;dual license




