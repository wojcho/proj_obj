(*Proszę napisać program w Pascalu, który zawiera dwie procedury, jedna
generuje listę 50 losowych liczb od 0 do 100. Druga procedura sortuje
liczbę za pomocą sortowania bąbelkowego.

3.0 Procedura do generowania 50 losowych liczb od 0 do 100
3.5 Procedura do sortowania liczb
4.0 Dodanie parametrów do procedury losującej określającymi zakres losowania: od, do, ile
4.5 5 testów jednostkowych testujące procedury
5.0 Skrypt w bashu do uruchamiania aplikacji w Pascalu via docker*)

unit array_utilities;

{$mode objfpc}

interface

uses
  sysutils;

procedure random_array(
  var random_numbers: array of integer;
  min, max, amount: integer
);
  
procedure bubble_sort(
  var to_sort: array of integer;
  length: integer
);

implementation

procedure random_array(
  var random_numbers: array of integer;
  min, max, amount: integer
);
var
  i: integer;
begin
  if (max < min) then
    raise Exception.Create('max > min');
  for i := 0 to amount - 1 do
    random_numbers[i] := random(max - min + 1) + min;
end;

procedure bubble_sort(
  var to_sort: array of integer;
  length: integer
);
var
  i, j, swap_helper: integer;
  is_swapped: boolean;
begin
  for i := 0 to length - 2 do
  begin
    is_swapped := false;
    for j := 0 to length - i - 2 do
    begin
      if (to_sort[j] > to_sort[j + 1]) then
      begin
        swap_helper := to_sort[j];
        to_sort[j] := to_sort[j + 1];
        to_sort[j + 1] := swap_helper;
        is_swapped := true;
      end;
    end;
    if (not is_swapped) then
      break;
  end;
end;

end.
