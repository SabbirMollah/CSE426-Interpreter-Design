#ifndef TERMH
#define TERMH

enum DataType {INT_TYPE, REAL_TYPE, CHAR_TYPE, STRING_TYPE, ID_TYPE};

typedef struct Term
{
   enum DataType dataType;
   union {
      float real_val;
      int int_val;
      char char_val;
      char *string_val;
   };
}Term;

#endif /* of TERMH */