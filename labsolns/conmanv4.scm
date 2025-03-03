(define-module (labsolns conmanv4)
   #:use-module (guix packages)
   #:use-module ((guix licenses) #:prefix license:)
   #:use-module (guix download)
   #:use-module (guix git-download)
   #:use-module (guix utils)
   #:use-module (guix build utils)
   #:use-module (guix build-system guile)
   #:use-module (guix build-system gnu)
   #:use-module (gnu packages bash)
   #:use-module (gnu packages)
   #:use-module (gnu packages tls)
   #:use-module (gnu packages nss)
   #:use-module (gnu packages autotools)
   #:use-module (gnu packages guile)
   #:use-module (gnu packages guile-xyz)
   #:use-module (gnu packages pkg-config)
   #:use-module (gnu packages texinfo)
;;   #:use-module (labsolns limsn)
   )

(define-public conmanv4
             (let ((commit "3a1d10d5d5fff60cddc3c500f4f34c39554e5de4")
        (revision "2"))
  (package
    (name "conmanv4")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/conmanv4.git")
             (commit commit)))
              (file-name (git-file-name name version))
              (sha256
             (base32 "0dl92qnxkv6ns4kgfdym1qr43gljclk1dkxjlqs4iv9rfv1zmqjv"))))
    (build-system guile-build-system)
    (arguments `(
		 #:phases (modify-phases %standard-phases
    			  (add-after 'unpack 'patch-prefix
				     (lambda* (#:key inputs outputs #:allow-other-keys)
				       (let ((out  (assoc-ref outputs "out")))					  
					 (substitute* '("conmanv4/env.scm" "scripts/conman.sh")
						      (("conmanstorepath")
						       out))					 
					 (substitute* '("scripts/conman.sh")
						      (("guileexecutable")
						       (string-append (assoc-ref inputs "guile") "/bin/guile")))
					 #t)))
       					 
		       		       (add-after 'patch-prefix 'augment-GUILE_LOAD_PATH
						  (lambda* (#:key inputs #:allow-other-keys)
						    (begin
						      (setenv "GUILE_LOAD_PATH"
							      (string-append
							       ".:"
							        (assoc-ref inputs "guile-gnutls")  "/share/guile/site/3.0:"
							        (assoc-ref inputs "gnutls")  "/share/guile/site/3.0:"
								(assoc-ref inputs "guile-dbi") "/share/guile/site/2.2:"
								(getenv "GUILE_LOAD_PATH")))
						     (setenv "GUILE_DBD_PATH"
							      (string-append
							        (assoc-ref inputs "guile-dbd-mysql")  "/lib"
							       )))
						    #t))
			  
		       (add-after 'augment-GUILE_LOAD_PATH 'make-conman-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (conman-dir (string-append out "/share/guile/site/3.0/conmanv4"))
				  (mkdir-p conman-dir)
				  (dummy (copy-recursively "./conmanv4" conman-dir))) 
			     #t)))
		       
			   (add-after 'make-conman-dir 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (scm3  "/share/guile/site/3.0")
					   (scm2  "/share/guile/site/2.2")
					   (go3   "/lib/guile/3.0/site-ccache")
					   (go2   "/lib/guile/2.2/site-ccache")
					   (guile-load-path (string-append  out scm3 ":"
									    (assoc-ref inputs "guile-gnutls") scm3 ":"
									    (assoc-ref inputs "gnutls") scm3 ":"
									    (assoc-ref inputs "guile-dbi") scm2))
					   (guile-load-compiled-path  (string-append  out go3 ":"
										      (assoc-ref inputs "guile-gnutls") go3 ":"
										      (assoc-ref inputs "gnutls") go3 ))
					   (guile-dbd-path (string-append  (assoc-ref inputs "guile-dbd-mysql") "/lib:"
									   (assoc-ref inputs "guile-dbi") "/lib"))
					   (all-files '("conman.sh")))				      
				      (map (lambda (file)
					     (begin
					       (install-file (string-append "./scripts/" file) bin-dir)
					       (chmod (string-append bin-dir "/" file) #o555 ) ;;read execute, no write
					       (wrap-program (string-append bin-dir "/" file)
							     `( "PATH" ":" prefix  (,bin-dir) )							     
							     `("GUILE_LOAD_PATH" ":" prefix (,guile-load-path ))
							     `("GUILE_LOAD_COMPILED_PATH" ":" prefix (,guile-load-compiled-path))
							     `("GUILE_DBD_PATH" ":" prefix (,guile-dbd-path))
							     )))
					     all-files))					   					   	    
				    #t))

			   (add-after 'make-bin-dir 'make-scripts-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/scripts"))
					   (all-files '("las.png")))				      
				      (map (lambda (file)
					     (begin
					       (install-file (string-append "./scripts/" file) scripts-dir)
					       ))
					     all-files))					   					   	    
				    #t))
			   
			  (add-after 'make-scripts-dir 'cp-smtp-cli
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin")))
				      (install-file "./bin/smtp-cli" bin-dir)
				      (chmod (string-append bin-dir "/smtp-cli") #o555 )
				      )
				    #t))

		       )))
  (native-inputs
   `(("guile" ,guile-3.0)
     ("texinfo" ,texinfo)
     ))
  (inputs `(("bash" ,bash-minimal)
	    ))
  (propagated-inputs `(("guile-gnutls" ,guile-gnutls)
		       ("gnutls" ,gnutls)
		       ("guile-dbi" ,guile-dbi)
		       ("guile-dbd-mysql" ,guile-dbd-mysql)
;;		       ("limsn" ,limsn)
		       ))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+))))


