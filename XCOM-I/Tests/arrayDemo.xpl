/* This is a test case for compilation of ARRAY. */

ARRAY VOCAB_INDEX(311) FIXED INITIAL(1, 2, 3, 4, 5);
ARRAY STRINGS(25) CHARACTER INITIAL('a', 'b', 'c', 'd');

VOCAB_INDEX(5) = 22;
OUTPUT = VOCAB_INDEX(5);

STRINGS(2) = 'hello';
OUTPUT = STRINGS(2);

EOF
