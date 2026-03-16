program test;

{$mode objfpc}

uses
  array_utilities,
  sysutils;

procedure test_sort_random_is_ordered();
var
  random_numbers: array of integer;
  i, random_numbers_length: integer;
  is_ordered: boolean;
begin
  random_numbers_length := 50;
  is_ordered := true;

  setlength(random_numbers, random_numbers_length);
  random_array(random_numbers, 0, 100, random_numbers_length);
  bubble_sort(random_numbers, random_numbers_length);

  for i := 0 to random_numbers_length - 2 do
  begin
    if (random_numbers[i + 1] < random_numbers[i]) then
    begin
      is_ordered := false;
      writeln('Wrong order between indices ', i, ' and ', i + 1, ' (values: ', random_numbers[i], ' > ', random_numbers[i + 1], ')');
    end;
  end;

  if (is_ordered) then
    writeln('CORRECT, all elements are ordered after running sort on random numbers')
  else
    writeln('MISTAKE!!!! NOT all elements are ordered after running sort on random numbers')
  ;
end;

procedure test_random_all_in_range();
var
  random_numbers: array of integer;
  i, random_numbers_length, min, max: integer;
  is_in_range: boolean;
begin
  random_numbers_length := 100;
  min := -10;
  max := 10;
  is_in_range := true;

  setlength(random_numbers, random_numbers_length);
  random_array(random_numbers, min, max, random_numbers_length);

  for i := 0 to random_numbers_length - 1 do
  begin
    if ((random_numbers[i] > max) or (random_numbers[i] < min)) then
    begin
      is_in_range := false;
      writeln('Value at index ', i, ' (value: ', random_numbers[i], ' outside range from: ', min, ' to: ', max, ')');
    end;
  end;

  if (is_in_range) then
    writeln('CORRECT, all random elements are in proper range')
  else
    writeln('MISTAKE!!!! NOT all random elements are in proper range')
  ;
end;

procedure test_random_only_until_length();
var
  random_numbers: array of integer;
  i, random_numbers_length, min, max, random_length, poison: integer;
  is_in_range, is_until_length: boolean;
begin
  random_numbers_length := 100;
  random_length := 50;
  poison := 10;
  min := 100;
  max := 1000;
  is_in_range := true;

  setlength(random_numbers, random_numbers_length);

  for i := 0 to random_numbers_length - 1 do
    random_numbers[i] := poison
  ;

  random_array(random_numbers, min, max, random_length);

  
  for i := 0 to random_length - 1 do
  begin
    if ((random_numbers[i] > max) or (random_numbers[i] < min)) then
    begin
      is_in_range := false;
      writeln('Value at index ', i, ' (value: ', random_numbers[i], ' outside range from: ', min, ' to: ', max, ')');
    end;
  end;

  for i := random_length to random_numbers_length - 1 do
  begin
    if (random_numbers[i] <> poison) then
    begin
      is_until_length := false;
      writeln('Value at index ', i, ' (value: ', random_numbers[i], ' should be: ', poison, ')');
    end;
  end;

  if (is_in_range or is_until_length) then
    writeln('CORRECT, all random elements are in proper range, and all values outside selected array part are not changed')
  else
    writeln('MISTAKE!!!! NOT all random elements are in proper range, or NOT all values outside selected array part are not changed')
  ;
end;

procedure test_random_min_max_swapped_exception();
var
  random_numbers: array of integer;
  is_raised: boolean;
begin
  is_raised := false;

  setlength(random_numbers, 100);

  try
    random_array(random_numbers, 100, -100, 100);
  except
    on E: Exception do
      is_raised := true;
  end;

  if (is_raised) then
    writeln('CORRECT, exception raised for swapped min and max')
  else
    writeln('MISTAKE!!!! exception was NOT raised for swapped min and max')
  ;
end;

procedure test_sort_does_not_omit();
var
  random_numbers: array of integer;
  i, random_numbers_length: integer;
  is_present: boolean;
begin
  random_numbers_length := 100;
  is_present := true;

  setlength(random_numbers, random_numbers_length);

  for i := 0 to random_numbers_length - 1 do
    random_numbers[i] := random_numbers_length - i - 1
  ;

  bubble_sort(random_numbers, random_numbers_length);

  for i := 0 to random_numbers_length - 1 do
  begin
    if (random_numbers[i] <> i) then
    begin
      is_present := false;
      writeln('Value at index ', i, ' (value: ', random_numbers[i], ' should be: ', i, ')');
    end;
  end;

  if (is_present) then
    writeln('CORRECT, all values from reverse sorted array were present in proper order after sorting')
  else
    writeln('MISTAKE!!!! NOT all values from reverse sorted array were present in proper order after sorting')
  ;
end;

begin
  test_sort_random_is_ordered();
  test_random_all_in_range();
  test_random_only_until_length();
  test_random_min_max_swapped_exception();
  test_sort_does_not_omit();
end.
