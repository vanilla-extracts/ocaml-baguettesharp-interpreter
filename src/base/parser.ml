module Parser = struct
  include Token

  type arguments = Str of string | I of int | Nul of unit | D of float | Bool of bool;;
  type parameters = CallExpression of string | Argument of arguments | GOTO of string | Exception of string | Label of string | IF | COND ;;
  type 'a ast = Nil | Node of 'a * ('a ast) list;;

  let parse_string_rec lst = 
    let rec parse acc lsts =
      match lsts with 
        | [] -> (String.trim acc,[])
        | Token.QUOTE::q -> (String.trim acc,q)
        | token::q -> parse (acc ^ " " ^ (Token.token_to_litteral_string token)) q
    in parse "" lst;;
    
    (*Only parse a callexpression and not a line ? => not important right now multiline is more important*)
     (*syntax of a label
  LABEL 0
  BEGIN
  LIGNE1
  LIGNE2
  LIGNE3
  END
  *)
  (*syntax of a IF: IF <cond> THEN BEGIN .... ... ... END -> Node(IF, [cond, label-like])*)
    let parse_line lst = 
      let rec aux last_token acc lst =
        match lst with
          | [] -> lst,List.rev acc
          (*basic handling*)
          | Token.LEFT_PARENTHESIS::q -> (match last_token with 
            | Token.STRING_TOKEN s -> let rest,accs = aux Token.LEFT_PARENTHESIS [] q in let acc' = if List.length acc > 0 then List.tl acc else [] in (aux Token.NULL_TOKEN (Node(CallExpression s, accs)::acc') rest)
            | _ -> aux Token.LEFT_PARENTHESIS acc q)
          | Token.RIGHT_PARENTHESIS::q -> q,List.rev acc
          | Token.SEMI_COLON::_ -> lst,List.rev acc
          
          (*KEYWORD and Quote handling*)
          | (Token.KEYWORD k)::q when String.equal k "IF" -> let rest,accs = aux (Token.KEYWORD k) [] q in
             (aux Token.NULL_TOKEN (Node(IF, accs)::acc) rest)

          | (Token.KEYWORD k)::q when String.equal k "BEGIN" -> 
            (match last_token with 
              | Token.KEYWORD k -> aux (Token.KEYWORD k) acc q
              | _ -> q,[Node(Exception "error syntax", [Nil])])
          
          | (Token.KEYWORD k)::q when String.equal k "THEN" -> 
            (match last_token with 
              | (Token.KEYWORD k) when String.equal k "IF" -> q,[Node(Exception "error syntax",[Nil])] 
              | _ -> aux (Token.KEYWORD k) [Node(COND, acc)] q)
          
            
          | Token.QUOTE::q -> let str,q2 = parse_string_rec q in 
            (match last_token with
              | Token.KEYWORD k when k="LABEL" -> let rest,accs = aux (Token.KEYWORD k) [] q2 in 
                  let acc' = if List.length acc > 0 then List.tl acc else [] in 
                  (aux Token.NULL_TOKEN (Node(Label str, accs)::acc') rest)
              | Token.KEYWORD k when k="GOTO" -> aux (Token.KEYWORD k) (Node(GOTO str, [Nil])::acc) q2
              | _ -> aux Token.QUOTE (Node(Argument (Str str), [Nil])::acc) q2)
                         
          | (Token.KEYWORD k)::q when k="GOTO" -> aux (Token.KEYWORD k) acc q
          | (Token.KEYWORD k)::q when String.equal k "LABEL" -> aux (Token.KEYWORD k) acc q
          | (Token.KEYWORD k)::q when String.equal k "END" -> q,List.rev acc
          
          
          (*Arguments handling*)
          | (Token.STRING_TOKEN s)::q -> if String.equal "" (String.trim s) then aux Token.NULL_TOKEN acc q else aux (Token.STRING_TOKEN s) (Node(Argument (Str s), [Nil])::acc) q
          | (Token.INT_TOKEN i)::q  -> aux (Token.INT_TOKEN i) (Node(Argument (I i), [Nil])::acc) q
          | (Token.FLOAT_TOKEN d)::q -> aux (Token.FLOAT_TOKEN d) (Node(Argument (D d), [Nil])::acc) q
          | (Token.BOOL_TOKEN f)::q -> aux (Token.BOOL_TOKEN f) (Node(Argument (Bool f), [Nil])::acc) q
          | _::q -> q,List.rev acc 
      in aux Token.NULL_TOKEN [] lst;;


    let create_int_argument param = Argument(I(param))
    let create_float_argument param = Argument(D(param))
    let create_bool_argument param = Argument(Bool(param))
    let create_string_argument param = Argument(Str(param))

    let add_numbers a b = 
      match a,b with 
        | Argument(I(i)),Argument(I(i')) -> create_int_argument (i + i')
        | Argument(I(i)),Argument(D(d)) -> create_float_argument ((float_of_int i) +. d)
        | Argument(D(d)),Argument(I(i)) -> create_float_argument ((float_of_int i) +. d)
        | Argument(D(d)),Argument(D(d')) -> create_float_argument (d +. d')
        | Argument(Str s),Argument(Str s') -> create_string_argument (s ^ s')
        | Argument(Str s),Argument(I i) -> create_string_argument (s ^ (string_of_int i))
        | Argument(Str s),Argument(D d) -> create_string_argument (s ^ (string_of_float d))
        | Argument(I i),Argument(Str s) -> create_string_argument ((string_of_int i) ^ s)
        | Argument(D d),Argument(Str s) -> create_string_argument ((string_of_float d) ^ s)
        | _ -> Exception "non summable" 
   
   let equality a b = 
      let aux a b =
        match a,b with 
          | Argument(I(i)),Argument(I(i')) ->  i=i'
          | Argument(I(i)),Argument(D(d)) -> (float_of_int i)=d
          | Argument(D(d)),Argument(I(i)) -> d=(float_of_int i)
          | Argument(D(d)),Argument(D(d')) -> d=d'
          | Argument(Str s),Argument(Str s') -> s=s'
          | Argument(Str s),Argument(I i) -> s=(string_of_int i)
          | Argument(Str s),Argument(D d) -> s=(string_of_float d)
          | Argument(I i),Argument(Str s) -> (string_of_int i)=s
          | Argument(D d),Argument(Str s) -> (string_of_float d)=s
          | _ -> false
      in create_bool_argument (aux a b);;

   let inferior_large a b = 
      let aux a b =
        match a,b with 
          | Argument(I(i)),Argument(I(i')) ->  i<=i'
          | Argument(I(i)),Argument(D(d)) -> (float_of_int i)<=d
          | Argument(D(d)),Argument(I(i)) -> d<=(float_of_int i)
          | Argument(D(d)),Argument(D(d')) -> d<=d'
          | Argument(Str s),Argument(Str s') -> s<=s'
          | Argument(Str s),Argument(I i) -> s<=(string_of_int i)
          | Argument(Str s),Argument(D d) -> s<=(string_of_float d)
          | Argument(I i),Argument(Str s) -> (string_of_int i)<=s
          | Argument(D d),Argument(Str s) -> (string_of_float d)<=s
          | _ -> false
      in create_bool_argument (aux a b);;

   let inferior a b = 
      let aux a b =
        match a,b with 
          | Argument(I(i)),Argument(I(i')) ->  i<i'
          | Argument(I(i)),Argument(D(d)) -> (float_of_int i)<d
          | Argument(D(d)),Argument(I(i)) -> d<(float_of_int i)
          | Argument(D(d)),Argument(D(d')) -> d<d'
          | Argument(Str s),Argument(Str s') -> s<s'
          | Argument(Str s),Argument(I i) -> s<(string_of_int i)
          | Argument(Str s),Argument(D d) -> s<(string_of_float d)
          | Argument(I i),Argument(Str s) -> (string_of_int i)<s
          | Argument(D d),Argument(Str s) -> (string_of_float d)<s
          | _ -> false
      in create_bool_argument (aux a b);;

   let superior_large a b = 
      let aux a b =
        match a,b with 
          | Argument(I(i)),Argument(I(i')) ->  i>=i'
          | Argument(I(i)),Argument(D(d)) -> (float_of_int i)>=d
          | Argument(D(d)),Argument(I(i)) -> d>=(float_of_int i)
          | Argument(D(d)),Argument(D(d')) -> d>=d'
          | Argument(Str s),Argument(Str s') -> s>=s'
          | Argument(Str s),Argument(I i) -> s>=(string_of_int i)
          | Argument(Str s),Argument(D d) -> s>=(string_of_float d)
          | Argument(I i),Argument(Str s) -> (string_of_int i)>=s
          | Argument(D d),Argument(Str s) -> (string_of_float d)>=s
          | _ -> false
      in create_bool_argument (aux a b);;

   let superior a b = 
      let aux a b =
        match a,b with 
          | Argument(I(i)),Argument(I(i')) ->  i>i'
          | Argument(I(i)),Argument(D(d)) -> (float_of_int i)>d
          | Argument(D(d)),Argument(I(i)) -> d>(float_of_int i)
          | Argument(D(d)),Argument(D(d')) -> d>d'
          | Argument(Str s),Argument(Str s') -> s>s'
          | Argument(Str s),Argument(I i) -> s>(string_of_int i)
          | Argument(Str s),Argument(D d) -> s>(string_of_float d)
          | Argument(I i),Argument(Str s) -> (string_of_int i)>s
          | Argument(D d),Argument(Str s) -> (string_of_float d)>s
          | _ -> false
      in create_bool_argument (aux a b);;

    let mult_numbers a b = 
      match a,b with 
        | Argument(I(i)),Argument(I(i')) -> create_int_argument (i * i')
        | Argument(I(i)),Argument(D(d)) -> create_float_argument ((float_of_int i) *. d)
        | Argument(D(d)),Argument(I(i)) -> create_float_argument ((float_of_int i) *. d)
        | Argument(D(d)),Argument(D(d')) -> create_float_argument (d *. d')
        | _ -> Exception "not numbers"

    
    let expn a b = 
      match a,b with 
        | Argument(I(i)),Argument(I(i')) -> create_int_argument (int_of_float(float_of_int i ** float_of_int i'))
        | Argument(I(i)),Argument(D(d)) -> create_float_argument ((float_of_int i) ** d)
        | Argument(D(d)),Argument(I(i)) -> create_float_argument (d ** (float_of_int i))
        | Argument(D(d)),Argument(D(d')) -> create_float_argument (d ** d')
        | _ -> Exception "not numbers"


    let divide_numbers a b = 
      match a,b with 
        | Argument(I(i)),Argument(I(i')) -> create_int_argument (i/i')
        | Argument(I(i)),Argument(D(d)) -> create_float_argument ((float_of_int i) /. d)
        | Argument(D(d)),Argument(I(i)) -> create_float_argument ((float_of_int i) /. d)
        | Argument(D(d)),Argument(D(d')) -> create_float_argument (d /. d')
        | _ -> Exception "not numbers"

    let substract_numbers a b = 
      match a,b with
        | Argument(I(i)),Argument(I(i')) -> create_int_argument (i - i')
        | Argument(I(i)),Argument(D(d)) -> create_float_argument ((float_of_int i) -. d)
        | Argument(D(d)),Argument(I(i)) -> create_float_argument ((float_of_int i) -. d)
        | Argument(D(d)),Argument(D(d')) -> create_float_argument (d -. d')
        | _ -> Exception "not numbers"
  
    let apply_binary_operator operator a b = 
      match a,b with 
        | Argument(Bool b),Argument(Bool b') -> create_bool_argument (operator b b')
        | _ -> Exception "not booleans";;
    
    let apply_unary_operator operator a = 
      match a with 
        | Argument(Bool b) -> create_bool_argument (operator b)
        | _ -> Exception "not boolean"
      
    let parse_file list_of_tokens = 
      let rec aux acc lst = 
        match lst with
          | [] -> acc;
          | Token.SEMI_COLON::[] -> acc
          | Token.SEMI_COLON::q -> let rest,accs = parse_line q in aux (acc @ accs) rest
          | _::q -> aux acc q
      in let rest,accs = parse_line list_of_tokens in aux accs rest;;

      let print_argument arg = 
        match arg with 
          | Str s -> "String: " ^ s
          | I i -> "Int: " ^ string_of_int i
          | D d -> "Float: " ^ string_of_float d
          | Bool b -> "Bool: " ^ string_of_bool b
          | Nul () -> "Nil";;


      

      let print_parameter param = 
        match param with 
          | CallExpression s -> "Fonction: " ^ s
          | Argument s -> "Argument: " ^ print_argument s
          | GOTO i -> "GOTO: " ^ i
          | Exception s -> "Exception " ^ s 
          | Label i -> "LABEL: " ^ i
          | IF -> "IF"
          | COND -> "COND"

      let print_pretty_arguments param = 
        String.concat " " (List.map print_parameter param);;

      let rec print_pretty_node node =
          match node with 
            | Nil -> ""
            | Node (parameter, arguments) -> "(" ^ print_parameter parameter ^ ") [" ^ (String.concat " " (List.map print_pretty_node arguments)) ^ "]"

    

end