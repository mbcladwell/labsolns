 
  (define-module (labsolns myapp)
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
  #:use-module ((srfi srfi-1) #:select (alist-delete)))

(define-public artanis-053
  (package
    (name "artanis")
    (version "0.5.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://gnu/artanis/artanis-0.5.1.tar.gz"))
              (sha256
               (base32
                "1zfg49s7wp37px7k22qcr06rxfwyn3gv1c3jmma346xw0m8jr63w"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  ;; Unbundle guile-redis and guile-json
                  (delete-file-recursively "artanis/third-party/json.scm")
                  (delete-file-recursively "artanis/third-party/json")
                  (delete-file-recursively "artanis/third-party/redis.scm")
                  (delete-file-recursively "artanis/third-party/redis")
                  (substitute* '("artanis/artanis.scm"
                                 "artanis/lpc.scm"
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
		
		  ;;============START forguix mods=========================================================================
		  ;;immutable-toplevel is the original current-toplevel in /gnu/store
		  ;;current-toplevel is the mutable toplevel in /tmp/myapp/tmp/cache
	
		   (substitute* "artanis/commands/work.scm"			      			       
				(("\\(let \\(\\(entry \\(string-append \\(current-toplevel\\) \"/\" \\*artanis-entry\\*\\)\\)\\)")
				 "(let ((entry (string-append (immutable-toplevel) \"/\" *artanis-entry*)))")
				(("\\(add-to-load-path \\(current-toplevel\\)\\)")
				 "(add-to-load-path (immutable-toplevel))")
				(("\\(add-to-load-path \\(string-append \\(current-toplevel\\) \"/lib\"\\)\\)")
				 "(add-to-load-path (string-append (immutable-toplevel) \"/lib\"))"))		
		   (substitute* '("artanis/tpl/parser.scm"
				  "artanis/mvc/controller.scm"
				  "artanis/webapi/restful.scm")			      			       
				(("current-toplevel")
				"immutable-toplevel"))				
		   (substitute* "artanis/utils.scm"			      			       
				(("\\(let\\* \\(\\(toplevel \\(current-toplevel\\)\\)")
				 "(let* ((toplevel (immutable-toplevel))")
				(("\\(current-toplevel\\) file\\)\\)\\)")
				"(immutable-toplevel) file)))")
				(("\\(if \\(current-toplevel\\)")
				 "(if (immutable-toplevel)")
				((" \\(let \\(\\(p \\(-> path\\)\\)\\)")
				  " (let ((p (-> path))(dummy (format (artanis-current-output) \"current-appname: ~a\" (current-appname) )))")
				(("\\(format \\#f \"~a/pub/~a\" \\(current-toplevel\\) path\\)")
				 "(format #f \"~a/pub/~a\" (immutable-toplevel) path)")
			;;	(("        \\(format \\#f \"~a\\/tmp\\/cache\\/index.html\" \\(current-toplevel\\)\\)")		 
			;;      	 "        (format #f \"/tmp/~a/tmp/cache/index.html\" (current-appname))")
			;;	(("\\(format \\#f \"~a\\/tmp\\/cache\\/~a.html\" \\(current-toplevel\\) \\(-> path\\)\\)\\)\\)\\)")
			;;	 "(format #f \"/tmp/~a/tmp/cache/~a.html\" (current-appname) (-> path)))))")
				)						  				
				
		   (substitute* "artanis/env.scm"
                                (("            current-toplevel\n")
                                 "            current-toplevel\n            %immutable-toplevel\n            immutable-toplevel\n")
                                (("\\(define \\(current-toplevel\\)\n")
                                         "(define %immutable-toplevel (make-parameter #f))\n")
                                (("  \\(or \\(%current-toplevel\\)\n")
                                         "  (define (immutable-toplevel)\n")
                                (("      \\(find-ENTRY-path identity #t\\)\\)\\)\n")
                        ;;       "     (or (%immutable-toplevel)\n         (find-ENTRY-path identity #t)))\n\n(define (current-toplevel) \"/tmp/myapp\")"))
                                 "     (or (%immutable-toplevel)\n         (find-ENTRY-path identity #t)))\n\n(define (current-toplevel) (string-append \"/tmp/\" (substring \"/myapp\" (+ (string-rindex \"/myapp\" #\\/) 1) (string-length \"/myapp\") ) ))")
                        ;;       "     (or (%immutable-toplevel)\n         (find-ENTRY-path identity #t)))\n\n(define (current-toplevel) (string-append \"/tmp/\" (substring %immutable-toplevel (+ (string-rindex %immutable-toplevel #\\/) 1) (string-length %immutable-toplevel) ) ))")
                               
                                )    ;;use of (current-appname) causes disk thrashing and freezing
				
				
;;   \"/myapp\"  should be replaced with (find-ENTRY-path identity #t)	   
	;;============END forguix mods=========================================================================
				   
                   (substitute* "artanis/artanis.scm"
                    (("[[:punct:][:space:]]+->json-string[[:punct:][:space:]]+")
                     ""))
                  #t)
	       )))
    (build-system gnu-build-system)
    (inputs
     `(("guile" ,guile-3.0)
       ("nss" ,nss)
       ("nspr" ,nspr)))
    ;; FIXME the bundled csv contains one more exported procedure
    ;; (sxml->csv-string) than guile-csv. The author is maintainer of both
    ;; projects.
    ;; TODO: Add guile-dbi and guile-dbd optional dependencies.
    (propagated-inputs
     `(("guile-json" ,guile-json-3) 
       ("guile-readline" ,guile-readline)
       ("guile-redis" ,guile-redis)))
    (native-inputs
     `(("bash"       ,bash)         ;for the `source' builtin
       ("pkgconfig"  ,pkg-config)
       ("util-linux" ,util-linux))) ;for the `script' command
    (arguments
     '(#:make-flags
       ;; TODO: The documentation must be built with the `docs' target.
       (let* ((out (assoc-ref %outputs "out"))
              (scm (string-append out "/share/guile/site/3.0"))
              (go  (string-append out "/lib/guile/3.0/site-ccache")))
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
         (add-before 'install 'substitute-root-dir
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out  (assoc-ref outputs "out")))
               (substitute* "Makefile"   ;ignore the execution of bash.bashrc
                 ((" /etc/bash.bashrc") " /dev/null"))
               (substitute* "Makefile"   ;set the root of config files to OUT
                 ((" /etc") (string-append " " out "/etc")))
               (mkdir-p (string-append out "/bin")) ;for the `art' executable
               #t)))
         (add-after 'install 'wrap-art
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (scm (string-append out "/share/guile/site/3.0"))
                    (go  (string-append out "/lib/guile/3.0/site-ccache")))
               (wrap-program (string-append bin "/art")
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
more. v0.5.1 contains feature enhancements required by LIMS*Nucleus")
    (home-page "https://www.gnu.org/software/artanis/")
    (license (list license:gpl3+ license:lgpl3+)))) ;dual license

(define-public myapp
  (package
    (name "myapp")
    (version "0.1.0")
;   (source "/home/admin/limsn-0.1.tar.gz")
   (source (origin
            (method url-fetch)
            ;;(uri (string-append "file:///home/admin/myapp-0.1.tar.gz"))
	    (uri (string-append "https://github.com/mbcladwell/myapp/releases/download/v0.1/myapp-0.1.tar.gz"))	    
            (sha256
             (base32
             "1nrvzj9csw47vc5m2wzlgd8gm4fqmbm0phkl9bd87321iq3a74hi"))));;anchor1
   (build-system gnu-build-system)
   
   (inputs (list guile-3.0 gnuplot))
   (propagated-inputs (list artanis-053 guile-json-3 guile-redis))
   (native-inputs (list bash pkg-config autoconf automake texinfo util-linux)) ;for the `script' command

   (arguments `(#:tests? #false ; there are none
			#:phases (modify-phases %standard-phases
    		       (add-after 'unpack 'patch-prefix
			       (lambda* (#:key inputs outputs #:allow-other-keys)
				 (substitute* '("./scripts/init-myapp.sh"
						"./scripts/start-myapp.sh"
						"./myapp/ENTRY")
					;;      	"./ENTRY")					      
						(("PATH_INTO_STORE")
						(assoc-ref outputs "out" )) )
				 #t))		       			       

		       (add-after 'unpack 'augment-GUILE_LOAD_PATH
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scm  "/share/guile/site/3.0:"))
				      (setenv "GUILE_LOAD_PATH"
					      (string-append out scm
					        out scm "/myapp:"	 ;;needed for libraries				       
					       (assoc-ref inputs "artanis") scm
					       (assoc-ref inputs "guile-json") scm
					       (assoc-ref inputs "guile-redis") scm
					       (getenv "GUILE_LOAD_PATH")))
				      #t)))
			
                       (add-before 'install 'make-lib-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (lib-dir (string-append out "/share/guile/site/3.0/myapp/lib"))
					   (dummy (mkdir-p lib-dir)))            				       
				       (copy-recursively "./myapp/lib" lib-dir)
				       #t)))
		     
                       (add-before 'install 'make-scripts-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/share/guile/site/3.0/myapp/scripts"))
					;;   (scripts-dir (string-append out "/scripts"))
					   (dummy (mkdir-p scripts-dir)))            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t)))
		      
		        (add-after 'install 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (scm  "/share/guile/site/3.0")
					   (go   "/lib/guile/3.0/site-ccache")
					   (all-files '("init-myapp.sh" "start-myapp.sh" )))				      
				      (map (lambda (file)
					     (begin
					       (install-file (string-append "./scripts/" file) bin-dir)
					       (chmod (string-append bin-dir "/" file) #o555 ) ;;read execute, no write
					       (wrap-program (string-append bin-dir "/" file)
							     `( "PATH" ":" prefix  (,bin-dir) )							     
							     `("GUILE_LOAD_PATH" prefix
							       (,(string-append out scm)
								))
							     `("GUILE_LOAD_COMPILED_PATH" prefix
							       (,(string-append out go)))
							     )))
					     all-files))					   					   	    
				      #t))
			)))
      (synopsis "Microwell Plate management Software")
    (description "description")
    (home-page "http://www.labsolns.com/")
    (license (list license:gpl3+ license:lgpl3+)))) ;dual license




