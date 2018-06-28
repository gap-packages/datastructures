##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

##
##  Memoisation with hash table
##
InstallGlobalFunction(MemoizeFunction,
function ( func, extra... )
    local cache, original, options, r;
    options := rec( flush := true,
                    contract := ReturnTrue,
                    errorHandler := function(args...) return fail; end
                  );
    if Length( extra ) > 0 then
        for r in RecNames( extra[1] ) do
            if IsBound( options.(r) ) then
                options.(r) := extra[1].(r);
            else
                ErrorNoReturn( "Invalid option: ", r );
            fi;
        od;
    fi;
    cache := HashMap();
    if options.flush then
        InstallMethod( FlushCaches, [  ], function (  )
                           cache := HashMap();
                           TryNextMethod();
                       end );
    fi;
    return function ( args... )
          local v;
          if not CallFuncList(options.contract, args) then
              v := CallFuncListWrap(options.errorHandler, args);
              if v <> [] then
                  return v[1];
              fi;
              return;
          fi;

          if args in cache then
              v := cache[args];
          else
              v := CallFuncList(func, args);
              cache[args] := v;
          fi;
          return v;
      end;
end);
