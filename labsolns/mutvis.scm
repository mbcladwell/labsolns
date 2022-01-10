(define-module (labsolns mutvis)
 #:use-module  (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
   #:use-module (gnu packages autotools)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages)
  #:use-module (gnu packages statistics)
  #:use-module (gnu packages cran))

(define-public mutvis
(package
  (name "mutvis")
  (version "0.1")
(source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "git://github.com/mbcladwell/mutvis.git")
                      (commit "2fd92a17a6a94f095595593dca2e6820f9895e9d")))
                (sha256 (base32 "1lz5nna7wxj68xk48bj1znwskwpfa8d6kl1vafnihn4jymm339x0"))
		))

  (build-system gnu-build-system)
  (arguments `(	#:phases (modify-phases %standard-phases												  
					(add-after 'unpack 'patch-prefix2
						   (lambda* (#:key inputs outputs #:allow-other-keys)
						     (substitute* '( "./scripts/mutvis.sh"								    
								    "./app.R")
								  (("abcdefgh")
								    (assoc-ref outputs "out" )  ))
						     #t))
					(add-after 'unpack 'copy-seqs
						   (lambda* (#:key outputs #:allow-other-keys)
						     (let* ((out  (assoc-ref outputs "out"))
							    )            				       
						       (install-file "./input.aln" out)
						       #t)))

					(add-after 'patch-source-shebangs 'copy-app
						    (lambda* (#:key outputs #:allow-other-keys)
						      (let* ((out  (assoc-ref outputs "out")))
							     (install-file "app.R" out)     			     	     
							     #t)))
					(add-after 'patch-source-shebangs 'copy-executable
						    (lambda* (#:key outputs #:allow-other-keys)
						      (let* ((out  (assoc-ref outputs "out"))
							     (bin-dir (string-append out "/bin"))							     	    						   		      )            				       
							(install-file "./scripts/mutvis.sh" bin-dir)
							#t)))
					(add-before 'configure 'wrap-seqeval
						   (lambda* (#:key inputs outputs #:allow-other-keys)
						     (let* ((out (assoc-ref outputs "out"))
							    (bin-dir (string-append out "/bin"))					   
							    (dummy (chmod (string-append out "/bin/mutvis.sh") #o555 )) ;;read execute, no write		
							    ) 
						       (wrap-program (string-append out "/bin/mutvis.sh")
								     `( "PATH" ":" prefix  (,bin-dir) ))
						       #t)))					
	      ) ))
  (native-inputs
    `(
      ("autoconf" ,autoconf)
      ("automake" ,automake)
      ("pkg-config" ,pkg-config)
      ("texinfo" ,texinfo)
      ))
  (inputs `(	  
	    ("guile" ,guile-3.0)
	  ))
  (propagated-inputs `(
		       ("r" ,r)
		       ("r-seqinr" ,r-seqinr)
		       ("r-shiny" ,r-shiny)
		       ("r-markdown" ,r-markdown)
		       ))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+)))

