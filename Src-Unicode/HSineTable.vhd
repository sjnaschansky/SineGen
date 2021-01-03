----------------------------------------------------------------------------------
-- Copyright (C) 2018 SN
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation and/or
-- other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its contributors
-- may be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
-- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
-- OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
-- OF THE POSSIBILITY OF SUCH DAMAGE.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.CONV_STD_LOGIC_VECTOR;

-- ПЗУ отсчётов синуса.
-- Таблица содержит половину периода - положительную полуволну, рассчитанную с шагом 360 / 256 = 1.41 град и масштабом 127.
-- Для симметричности значений таблицы относительно её центра введён сдвиг равный половине шага 360 / 512.
-- Т.е. первый отсчёт   = Round (127 * sin (360 / 256 * 0 + 360 / 512)) = 2
-- Второй отсчёт        = Round (127 * sin (360 / 256 * 1 + 360 / 512)) = 5
-- ...
-- Предпоследний отсчёт = Round (127 * sin (360 / 256 * 126 + 360 / 512)) = 5
-- Последний отсчёт     = Round (127 * sin (360 / 256 * 127 + 360 / 512)) = 2

-- Значения представлены в 7-ми битном формате, после получения отрицательной полуволны сменой знака разрядность увеличится до 8 бит.

entity HSineTable is
  port (
    Binary : in STD_LOGIC_VECTOR (6 downto 0);
    Sine : out STD_LOGIC_VECTOR (6 downto 0)
  );
end HSineTable;

architecture ArcHSineTable of HSineTable is

begin

  process (Binary)
  begin
    case (Binary) is

      when CONV_STD_LOGIC_VECTOR (0, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (2, Sine'length);
      when CONV_STD_LOGIC_VECTOR (127, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (2, Sine'length);

      when CONV_STD_LOGIC_VECTOR (1, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (5, Sine'length);
      when CONV_STD_LOGIC_VECTOR (126, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (5, Sine'length);

      when CONV_STD_LOGIC_VECTOR (2, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (8, Sine'length);
      when CONV_STD_LOGIC_VECTOR (125, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (8, Sine'length);

      when CONV_STD_LOGIC_VECTOR (3, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (11, Sine'length);
      when CONV_STD_LOGIC_VECTOR (124, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (11, Sine'length);

      when CONV_STD_LOGIC_VECTOR (4, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (14, Sine'length);
      when CONV_STD_LOGIC_VECTOR (123, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (14, Sine'length);

      when CONV_STD_LOGIC_VECTOR (5, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (17, Sine'length);
      when CONV_STD_LOGIC_VECTOR (122, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (17, Sine'length);

      when CONV_STD_LOGIC_VECTOR (6, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (20, Sine'length);
      when CONV_STD_LOGIC_VECTOR (121, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (20, Sine'length);

      when CONV_STD_LOGIC_VECTOR (7, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (23, Sine'length);
      when CONV_STD_LOGIC_VECTOR (120, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (23, Sine'length);

      when CONV_STD_LOGIC_VECTOR (8, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (26, Sine'length);
      when CONV_STD_LOGIC_VECTOR (119, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (26, Sine'length);

      when CONV_STD_LOGIC_VECTOR (9, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (29, Sine'length);
      when CONV_STD_LOGIC_VECTOR (118, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (29, Sine'length);

      when CONV_STD_LOGIC_VECTOR (10, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (32, Sine'length);
      when CONV_STD_LOGIC_VECTOR (117, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (32, Sine'length);

      when CONV_STD_LOGIC_VECTOR (11, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (35, Sine'length);
      when CONV_STD_LOGIC_VECTOR (116, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (35, Sine'length);

      when CONV_STD_LOGIC_VECTOR (12, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (38, Sine'length);
      when CONV_STD_LOGIC_VECTOR (115, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (38, Sine'length);

      when CONV_STD_LOGIC_VECTOR (13, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (41, Sine'length);
      when CONV_STD_LOGIC_VECTOR (114, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (41, Sine'length);

      when CONV_STD_LOGIC_VECTOR (14, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (44, Sine'length);
      when CONV_STD_LOGIC_VECTOR (113, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (44, Sine'length);

      when CONV_STD_LOGIC_VECTOR (15, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (47, Sine'length);
      when CONV_STD_LOGIC_VECTOR (112, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (47, Sine'length);

      when CONV_STD_LOGIC_VECTOR (16, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (50, Sine'length);
      when CONV_STD_LOGIC_VECTOR (111, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (50, Sine'length);

      when CONV_STD_LOGIC_VECTOR (17, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (53, Sine'length);
      when CONV_STD_LOGIC_VECTOR (110, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (53, Sine'length);

      when CONV_STD_LOGIC_VECTOR (18, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (56, Sine'length);
      when CONV_STD_LOGIC_VECTOR (109, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (56, Sine'length);

      when CONV_STD_LOGIC_VECTOR (19, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (58, Sine'length);
      when CONV_STD_LOGIC_VECTOR (108, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (58, Sine'length);

      when CONV_STD_LOGIC_VECTOR (20, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (61, Sine'length);
      when CONV_STD_LOGIC_VECTOR (107, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (61, Sine'length);

      when CONV_STD_LOGIC_VECTOR (21, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (64, Sine'length);
      when CONV_STD_LOGIC_VECTOR (106, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (64, Sine'length);

      when CONV_STD_LOGIC_VECTOR (22, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (67, Sine'length);
      when CONV_STD_LOGIC_VECTOR (105, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (67, Sine'length);

      when CONV_STD_LOGIC_VECTOR (23, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (69, Sine'length);
      when CONV_STD_LOGIC_VECTOR (104, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (69, Sine'length);

      when CONV_STD_LOGIC_VECTOR (24, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (72, Sine'length);
      when CONV_STD_LOGIC_VECTOR (103, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (72, Sine'length);

      when CONV_STD_LOGIC_VECTOR (25, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (74, Sine'length);
      when CONV_STD_LOGIC_VECTOR (102, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (74, Sine'length);

      when CONV_STD_LOGIC_VECTOR (26, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (77, Sine'length);
      when CONV_STD_LOGIC_VECTOR (101, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (77, Sine'length);

      when CONV_STD_LOGIC_VECTOR (27, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (79, Sine'length);
      when CONV_STD_LOGIC_VECTOR (100, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (79, Sine'length);

      when CONV_STD_LOGIC_VECTOR (28, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (82, Sine'length);
      when CONV_STD_LOGIC_VECTOR (99, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (82, Sine'length);

      when CONV_STD_LOGIC_VECTOR (29, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (84, Sine'length);
      when CONV_STD_LOGIC_VECTOR (98, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (84, Sine'length);

      when CONV_STD_LOGIC_VECTOR (30, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (86, Sine'length);
      when CONV_STD_LOGIC_VECTOR (97, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (86, Sine'length);

      when CONV_STD_LOGIC_VECTOR (31, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (89, Sine'length);
      when CONV_STD_LOGIC_VECTOR (96, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (89, Sine'length);

      when CONV_STD_LOGIC_VECTOR (32, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (91, Sine'length);
      when CONV_STD_LOGIC_VECTOR (95, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (91, Sine'length);

      when CONV_STD_LOGIC_VECTOR (33, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (93, Sine'length);
      when CONV_STD_LOGIC_VECTOR (94, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (93, Sine'length);

      when CONV_STD_LOGIC_VECTOR (34, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (95, Sine'length);
      when CONV_STD_LOGIC_VECTOR (93, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (95, Sine'length);

      when CONV_STD_LOGIC_VECTOR (35, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (97, Sine'length);
      when CONV_STD_LOGIC_VECTOR (92, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (97, Sine'length);

      when CONV_STD_LOGIC_VECTOR (36, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (99, Sine'length);
      when CONV_STD_LOGIC_VECTOR (91, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (99, Sine'length);

      when CONV_STD_LOGIC_VECTOR (37, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (101, Sine'length);
      when CONV_STD_LOGIC_VECTOR (90, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (101, Sine'length);

      when CONV_STD_LOGIC_VECTOR (38, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (103, Sine'length);
      when CONV_STD_LOGIC_VECTOR (89, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (103, Sine'length);

      when CONV_STD_LOGIC_VECTOR (39, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (105, Sine'length);
      when CONV_STD_LOGIC_VECTOR (88, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (105, Sine'length);

      when CONV_STD_LOGIC_VECTOR (40, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (106, Sine'length);
      when CONV_STD_LOGIC_VECTOR (87, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (106, Sine'length);

      when CONV_STD_LOGIC_VECTOR (41, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (108, Sine'length);
      when CONV_STD_LOGIC_VECTOR (86, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (108, Sine'length);

      when CONV_STD_LOGIC_VECTOR (42, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (110, Sine'length);
      when CONV_STD_LOGIC_VECTOR (85, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (110, Sine'length);

      when CONV_STD_LOGIC_VECTOR (43, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (111, Sine'length);
      when CONV_STD_LOGIC_VECTOR (84, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (111, Sine'length);

      when CONV_STD_LOGIC_VECTOR (44, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (113, Sine'length);
      when CONV_STD_LOGIC_VECTOR (83, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (113, Sine'length);

      when CONV_STD_LOGIC_VECTOR (45, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (114, Sine'length);
      when CONV_STD_LOGIC_VECTOR (82, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (114, Sine'length);

      when CONV_STD_LOGIC_VECTOR (46, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (115, Sine'length);
      when CONV_STD_LOGIC_VECTOR (81, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (115, Sine'length);

      when CONV_STD_LOGIC_VECTOR (47, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (117, Sine'length);
      when CONV_STD_LOGIC_VECTOR (80, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (117, Sine'length);

      when CONV_STD_LOGIC_VECTOR (48, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (118, Sine'length);
      when CONV_STD_LOGIC_VECTOR (79, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (118, Sine'length);

      when CONV_STD_LOGIC_VECTOR (49, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (119, Sine'length);
      when CONV_STD_LOGIC_VECTOR (78, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (119, Sine'length);

      when CONV_STD_LOGIC_VECTOR (50, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (120, Sine'length);
      when CONV_STD_LOGIC_VECTOR (77, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (120, Sine'length);

      when CONV_STD_LOGIC_VECTOR (51, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (121, Sine'length);
      when CONV_STD_LOGIC_VECTOR (76, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (121, Sine'length);

      when CONV_STD_LOGIC_VECTOR (52, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (122, Sine'length);
      when CONV_STD_LOGIC_VECTOR (75, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (122, Sine'length);

      when CONV_STD_LOGIC_VECTOR (53, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (123, Sine'length);
      when CONV_STD_LOGIC_VECTOR (74, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (123, Sine'length);

      when CONV_STD_LOGIC_VECTOR (54, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (124, Sine'length);
      when CONV_STD_LOGIC_VECTOR (73, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (124, Sine'length);

      when CONV_STD_LOGIC_VECTOR (55, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (124, Sine'length);
      when CONV_STD_LOGIC_VECTOR (72, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (124, Sine'length);

      when CONV_STD_LOGIC_VECTOR (56, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (125, Sine'length);
      when CONV_STD_LOGIC_VECTOR (71, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (125, Sine'length);

      when CONV_STD_LOGIC_VECTOR (57, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (125, Sine'length);
      when CONV_STD_LOGIC_VECTOR (70, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (125, Sine'length);

      when CONV_STD_LOGIC_VECTOR (58, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (126, Sine'length);
      when CONV_STD_LOGIC_VECTOR (69, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (126, Sine'length);

      when CONV_STD_LOGIC_VECTOR (59, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (126, Sine'length);
      when CONV_STD_LOGIC_VECTOR (68, Binary'length) => Sine <= CONV_STD_LOGIC_VECTOR (126, Sine'length);

      when others => Sine <= CONV_STD_LOGIC_VECTOR (127, Sine'length);
    end case;
  end process;

end ArcHSineTable;
