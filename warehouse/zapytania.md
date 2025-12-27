1. Porównaj średnie opóźnienie z kursów dla każdego przewoźnika pociągów w roku 2023.
  SELECT NON EMPTY { [Measures].[Avg Roznica Czasu] } ON COLUMNS, NON EMPTY { ([Pociag].[Przewoznik].[Przewoznik].ALLMEMBERS * [Planowa Data Odjazdu].[Rok].[Rok].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM ( SELECT ( { [Planowa Data Odjazdu].[Rok].&[2023] } ) ON COLUMNS FROM [Pociagi Hurtownia]) CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

2. Które pociągi średnio spóźniają się dłużej – te prowadzone przez doświadczone w zawodzie kobiety, czy prowadzone przez niedoświadczonych
mężczyzn?
 SELECT NON EMPTY { [Measures].[Avg Roznica Czasu] } ON COLUMNS, NON EMPTY { ([Maszynista].[Plec].[Plec].ALLMEMBERS * [Maszynista].[Doswiadczenie Pracy].[Doswiadczenie Pracy].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

3. Porównaj, liczbę wypadków na przejazdach kolejowych ze światłami i rogatkami, jak i bez 
nich.
 SELECT NON EMPTY { [Measures].[Zdarzenie Na Trasie Count] } ON COLUMNS, NON EMPTY { ([Przejazd].[Czy Rogatki].[Czy Rogatki].ALLMEMBERS * [Przejazd].[Czy Sygnalizacja Swietlna].[Czy Sygnalizacja Swietlna].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS


4. Którego przewoznika pociągi wywołują incydenty o największych kosztach napraw

 SELECT NON EMPTY { [Measures].[Koszt Naprawy] } ON COLUMNS, NON EMPTY { ([Pociag].[Przewoznik].[Przewoznik].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

5. Pomiędzy którymi stacjami doszło do zranienia i śmierci największej liczby osób

 SELECT NON EMPTY { [Measures].[Liczba poszkodowanych] } ON COLUMNS, NON EMPTY { ([Stacja Wjazdowa].[Nazwa].[Nazwa].ALLMEMBERS * [Stacja Wyjazdowa].[Nazwa].[Nazwa].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

6. Jakiej skali niebezpieczeństwa zdarzenia generują średnio najmniejsze dodatkowe 
opóźnienia?

 SELECT NON EMPTY { [Measures].[Avg Wywolane Opoznienie] } ON COLUMNS, NON EMPTY { ([Zdarzenie].[Skala Niebezpieczenstwa].[Skala Niebezpieczenstwa].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

7. Porownaj liczbe zdarzen w rozne pory roku i dnia.
 SELECT NON EMPTY { [Measures].[Zdarzenie Na Trasie Count] } ON COLUMNS, NON EMPTY { ([Id Data Zdarzenia].[Pora Roku].[Pora Roku].ALLMEMBERS * [Id Czas Zdarzenia].[Pora Dnia].[Pora Dnia].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

8. Ile bylo kursow z opoznieniem , gdy padal deszcz w poszczegolnych miesiacach ? 
 SELECT NON EMPTY { [Measures].[Avg Roznica Czasu] } ON COLUMNS, NON EMPTY { ([Junk Odcinek Kursu].[Typ Opadow].[Typ Opadow].ALLMEMBERS * [Planowa Data Odjazdu].[Miesiac].[Miesiac].ALLMEMBERS * [Odcinek Kursu].[Id].[Id].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM ( SELECT ( { [Junk Odcinek Kursu].[Typ Opadow].&[deszcz] } ) ON COLUMNS FROM [Pociagi Hurtownia]) CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS

9. Podczas, jak wielu wypadków z pojazdem padał deszcz i interweniowały wtedy służby? 

 SELECT NON EMPTY { [Measures].[Zdarzenie Na Trasie Count] } ON COLUMNS, NON EMPTY { ([Junk Zdarzenie].[Czy Interwencja Sluzb].[Czy Interwencja Sluzb].ALLMEMBERS * [Junk Odcinek Kursu].[Typ Opadow].[Typ Opadow].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM ( SELECT ( { [Junk Odcinek Kursu].[Typ Opadow].&[deszcz] } ) ON COLUMNS FROM ( SELECT ( { [Junk Zdarzenie].[Czy Interwencja Sluzb].&[True] } ) ON COLUMNS FROM [Pociagi Hurtownia])) CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS


10. Dla kazdego kursu znajdz max/min/avg temperature w trakcie niego
  SELECT NON EMPTY { [Measures].[Avg Temperatura], [Measures].[Max Temperatura], [Measures].[Min Temperatura] } ON COLUMNS, NON EMPTY { ([Kurs].[Id].[Id].ALLMEMBERS ) } DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS FROM [Pociagi Hurtownia] CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS
