/* A test for compilation of strings. */

COMMON S0 CHARACTER;
COMMON S1(3) CHARACTER;
DECLARE S2 CHARACTER INITIAL('STRING2');
DECLARE S3(3) CHARACTER INITIAL('STRING3_0', 'STRING3_1', 'STRING3_2',
                                'STRING3_3');
DECLARE S4(3) CHARACTER INITIAL('STRING4_0', 'STRING4_1');

S0 = S3(2) || ' ' || S2;
OUTPUT = S0;
OUTPUT = SUBSTR(S3(1), 6, 1);

S2 = 'You are super-duper!';
S3(2) = 'Now is the time for all good men to come to the aid of their party.';

EOF
