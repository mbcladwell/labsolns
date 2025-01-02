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
  #:use-module ((srfi srfi-1) #:select (alist-delete)))

(define-public limsn
             (let ((commit "918267aa24b679092d1c17ba84a962cafa497d11");;anchor1
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
             (base32 "11vdm0ik40dm10impg9lx7gj3riwzn9dfa2j44vrza09jawvk1m3"))));;anchor2
  
   
   (build-system guile-build-system)
  (arguments `(
	       #:phases (modify-phases %standard-phases
    				       (add-after 'unpack 'patch-prefix
						  (lambda* (#:key inputs outputs #:allow-other-keys)
						     (let ((out  (assoc-ref outputs "out")))
						       (substitute* '("./limsn/lib/lnpg.scm"
								      "./limsn/ENTRY"
								      "./scripts/init-limsn-channel.sh"
								      "./scripts/init-limsn-pack.sh"
								      "./scripts/install-pg-aws-ec2.sh"
								      "./scripts/install-pg-aws-rds.sh"
								      "./scripts/lnpg.sh"
								      "./scripts/load-pg.sh"
								      "./scripts/start-limsn.sh"
								      )						
								    (("pathintostore")
								     out )))
						     #t))
		       		       
		       		       (add-after 'patch-prefix 'augment-GUILE_LOAD_PATH
						  (lambda* (#:key inputs #:allow-other-keys)
						    (begin
						      (setenv "GUILE_LOAD_PATH"
							      (string-append
							       ".:./limsn/lib:"
							        (assoc-ref inputs "guile-json")  "/share/guile/site/3.0:"
							        (assoc-ref inputs "artanis")  "/share/guile/site/3.0:"
								(assoc-ref inputs "guile-redis") "/share/guile/site/3.0:"
								(assoc-ref inputs "guile-dbi") "/share/guile/site/3.0:"
								(getenv "GUILE_LOAD_PATH")))
						     (setenv "GUILE_DBD_PATH"
							      (string-append
							        (assoc-ref inputs "guile-dbd-postgresql")  "/lib"
							       ))
						    )
						    #t))

                       (add-after 'augment-GUILE_LOAD_PATH 'make-lib-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (lib-dir (string-append out "/share/guile/site/3.0/limsn/lib"))
					   (dummy (mkdir-p lib-dir)))            				       
				       (copy-recursively "./limsn/lib" lib-dir)
				       #t)))

	       (add-after 'make-lib-dir 'make-accessory-dirs
				  (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (app-dir (string-append out "/share/guile/site/3.0/limsn/"))
					   (_ (install-file "./limsn/ENTRY" app-dir))
					   (conf-dir (string-append app-dir "conf"))
					   (postgres-dir (string-append app-dir "postgres"))
					   (pub-dir (string-append app-dir "pub"))
					   (sys-dir (string-append app-dir "sys"))
					   (tmp-dir (string-append app-dir "tmp"))
					   (all-dirs `(("./limsn/conf" ,conf-dir)
						       ("./limsn/postgres" ,postgres-dir)
						       ("./limsn/pub" ,pub-dir)
						       ("./limsn/sys" ,sys-dir)
						       ("./limsn/tmp" ,tmp-dir))))
            			        (map (lambda (dir)
					       (begin
						(mkdir-p (cadr dir))
						(copy-recursively (car dir) (cadr dir))
						))
					   all-dirs))))
		    
			   (add-after 'make-accessory-dirs 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (guile-load-path (string-append  out "/share/guile/site/3.0:"
									    (assoc-ref inputs "guile-json") "/share/guile/site/3.0:"
									    (assoc-ref inputs "artanis") "/share/guile/site/3.0:"
									    (assoc-ref inputs "guile-redis") "/share/guile/site/3.0:"
									    (assoc-ref inputs "guile-dbi") "/share/guile/site/2.2"))
					   (guile-dbd-path (string-append  (assoc-ref inputs "guile-dbd-postgresql") "/lib"))
					   (_ (mkdir-p bin-dir))                
					   (_ (copy-recursively "./scripts" bin-dir))
					   (scm  (string-append  out "/share/guile/site/3.0"))
					   (wrap-bin (string-append  out "/bin"))
					 ;;  (go   "/lib/guile/3.0/site-ccache")
					   (all-files '("/start-limsn.sh" "/init-limsn-pack.sh" "/load-pg.sh"
							"/lnpg.sh" "/init-limsn-channel.sh" "/install-pg-aws-ec2.sh"
							"/install-pg-aws-rds.sh")))				      
				      (map (lambda (file)
					     (begin
					       (chmod (string-append bin-dir file) #o555 )
					       (wrap-program (string-append  bin-dir file)
							     `( "PATH" ":" prefix  (,wrap-bin) )
							     `("GUILE_LOAD_PATH" ":" prefix (,guile-load-path))
							     `("GUILE_DBD_PATH" ":" prefix (,guile-dbd-path))
							     )))
					   all-files))				    
				    #t))

			   
			   )))
    (inputs
     `(("guile" ,guile-3.0)
       ("gnuplot" ,gnuplot)
       ("guile-dbi" ,guile-dbi)
       ))
    (propagated-inputs
     `(
       ("artanis" ,artanis)
       ("guile-json" ,guile-json-3)
       ("guile-redis" ,guile-redis)
       ("guile-dbd-postgresql" ,guile-dbd-postgresql)
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

