! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: parser generic kernel classes words slots assocs sequences arrays
vectors definitions prettyprint combinators.lib math hashtables sets ;
IN: delegate

: protocol-words ( protocol -- words )
    \ protocol-words word-prop ;

: protocol-consult ( protocol -- consulters )
    \ protocol-consult word-prop ;

GENERIC: group-words ( group -- words )

M: tuple-class group-words
    "slot-names" word-prop [
        [ reader-word ] [ writer-word ] bi
        2array [ 0 2array ] map
    ] map concat ;

! Consultation

: consult-method ( word class quot -- )
    [ drop swap first create-method ]
    [ nip swap first2 swapd [ ndip ] 2curry swap suffix ] 3bi define ;

: change-word-prop ( word prop quot -- )
    rot word-props swap change-at ; inline

: register-protocol ( group class quot -- )
    rot \ protocol-consult [ swapd ?set-at ] change-word-prop ;

: define-consult ( group class quot -- )
    [ register-protocol ] [
        rot group-words -rot
        [ consult-method ] 2curry each
    ] 3bi ;

: CONSULT:
    scan-word scan-word parse-definition define-consult ; parsing

! Protocols

: cross-2each ( seq1 seq2 quot -- )
    [ with each ] 2curry each ; inline

: forget-all-methods ( classes words -- )
    [ 2array forget ] cross-2each ;

: protocol-users ( protocol -- users )
    protocol-consult keys ;

: lost-words ( protocol wordlist -- lost-words )
    >r protocol-words r> diff ;

: forget-old-definitions ( protocol new-wordlist -- )
    >r [ protocol-users ] [ protocol-words ] bi r>
    swap diff forget-all-methods ;

: added-words ( protocol wordlist -- added-words )
    swap protocol-words swap diff ;

: add-new-definitions ( protocol wordlist -- )
     dupd added-words >r protocol-consult >alist r>
     [ first2 consult-method ] cross-2each ;

: initialize-protocol-props ( protocol wordlist -- )
    [ drop H{ } clone \ protocol-consult set-word-prop ]
    [ { } like \ protocol-words set-word-prop ] 2bi ;

: fill-in-depth ( wordlist -- wordlist' )
    [ dup word? [ 0 2array ] when ] map ;

: define-protocol ( protocol wordlist -- )
    fill-in-depth
    [ forget-old-definitions ]
    [ add-new-definitions ]
    [ initialize-protocol-props ] 2tri ;

: PROTOCOL:
    CREATE-WORD
    [ define-symbol ]
    [ f "inline" set-word-prop ]
    [ parse-definition define-protocol ] tri ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ f forget-old-definitions ] [ call-next-method ] bi ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol synopsis* word-synopsis ; ! Necessary?

M: protocol group-words protocol-words ;
