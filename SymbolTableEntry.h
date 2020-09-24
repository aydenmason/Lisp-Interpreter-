#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define UNDEFINED  			-1   // Type codes
#define INT				1

#define INT_OR_STR			3
#define BOOL				4
#define INT_OR_BOOL			5
#define STR_OR_BOOL			6
#define INT_OR_STR_OR_BOOL		7
#define STR				2
 
#define NOT_APPLICABLE 	-1

typedef struct 
{
  bool valBOOL;
  char* valSTR;
  int valINT;
  int type;       // one of the above type codes
 
  int returnType;
} TYPE_INFO;

class SYMBOL_TABLE_ENTRY 
{
private:
  // Member variables
  string name;
  TYPE_INFO typeInfo;

public:
  // Constructors
  SYMBOL_TABLE_ENTRY( ) 
  { 
    name = ""; 
    typeInfo.type = UNDEFINED;
    //typeInfo.valSTR = 'x';
    typeInfo.valINT = UNDEFINED;
    typeInfo.valBOOL = UNDEFINED;
  }

  SYMBOL_TABLE_ENTRY(const string theName, 
                     const TYPE_INFO theType, const int val,  char* strval, const bool boolval) 
  {
    name = theName;
    typeInfo.type = theType.type;
    typeInfo.valINT = val;
    typeInfo.valSTR = strval;
    typeInfo.valBOOL = boolval;

  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO getTypeInfo() const { return typeInfo; }
};

#endif  // SYMBOL_TABLE_ENTRY_H
