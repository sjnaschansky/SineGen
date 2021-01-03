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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SinGenerator6 is
  generic (
    UserInterfaceCtrWidth : Natural := 12; -- Разрядность счётчика делителя пользовательского интерфейса.
    ButtonTimeOutCtrWidth : Natural := 8; -- Разрядность счётчика формирователя задержки для обработки сигналов кнопки.
    PhaseRegWidth : Natural := 8; -- Разрядность регистров хранения сдвигов фазы.
    FreqNumRegWidth : Natural := 4; -- Разрядность регистра хранения номера генерируемой частоты.
    WaveformTypeRegWidth : Natural := 2; -- Разрядность регистра хранения номера формы генерируемого сигнала.
    SigGenCtrWidth : Natural := 6; -- Разрядность счётчика делителя частоты генератора сигналов.
    AmpRegWidth : Natural := 8 -- Разрядность регистров хранения амплитуд.
  );
  port (
    -- Вход тактового сигнала.
    Clk : in STD_LOGIC;
    -- Входы переключателей.
    SW0, SW1 : in STD_LOGIC; -- Переключатели используются для запуска и остановки генерации, а также для переключения между установкой частоты и установкой сдвига фазы.
    -- Входы кнопок.
    BTN0, BTN1 : in STD_LOGIC; -- Кнопки используются для установки частоты и установки сдвига фазы.
    -- Выход к первому модулю ЦАП.
    DAC12_Clk : out STD_LOGIC;
    DAC12_nLE_R : out STD_LOGIC;
    DAC1_Data_R, DAC2_Data_R : out STD_LOGIC;
    -- Дополнительные выводы, к которым может быть подключен первый модуль ЦАП.
    DAC12_Clk_Copy : out STD_LOGIC;
    DAC12_nLE_R_Copy : out STD_LOGIC;
    DAC1_Data_R_Copy, DAC2_Data_R_Copy : out STD_LOGIC;
    -- Выход ко второму модулю ЦАП.
    DAC34_Clk : out STD_LOGIC;
    DAC34_nLE_R : out STD_LOGIC;
    DAC3_Data_R, DAC4_Data_R : out STD_LOGIC;
    -- Дополнительные выводы, к которым может быть подключен второй модуль ЦАП.
    DAC34_Clk_Copy : out STD_LOGIC;
    DAC34_nLE_R_Copy : out STD_LOGIC;
    DAC3_Data_R_Copy, DAC4_Data_R_Copy : out STD_LOGIC;
    -- Выход к третьему модулю ЦАП.
    DAC56_Clk : out STD_LOGIC;
    DAC56_nLE_R : out STD_LOGIC;
    DAC5_Data_R, DAC6_Data_R : out STD_LOGIC;
    -- Дополнительные выводы, к которым может быть подключен третий модуль ЦАП.
    DAC56_Clk_Copy : out STD_LOGIC;
    DAC56_nLE_R_Copy : out STD_LOGIC;
    DAC5_Data_R_Copy, DAC6_Data_R_Copy : out STD_LOGIC;
    -- Выход к четвёртому модулю ЦАП.
    DAC78_Clk : out STD_LOGIC;
    DAC78_nLE_R : out STD_LOGIC;
    DAC7_Data_R, DAC8_Data_R : out STD_LOGIC;
    -- Дополнительные выводы, к которым может быть подключен четвёртый модуль ЦАП.
    DAC78_Clk_Copy : out STD_LOGIC;
    DAC78_nLE_R_Copy : out STD_LOGIC;
    DAC7_Data_R_Copy, DAC8_Data_R_Copy : out STD_LOGIC;
    -- Выходы к светодиодам.
    LD0, LD1, LD2, LD3 : out STD_LOGIC;
    -- Семисегментный индикатор.
    -- Аноды.
    Digit0 : out STD_LOGIC;
    Digit1 : out STD_LOGIC;
    Digit2 : out STD_LOGIC;
    Digit3 : out STD_LOGIC;
    -- Катоды.
    CA : out STD_LOGIC;
    CB : out STD_LOGIC;
    CC : out STD_LOGIC;
    CD : out STD_LOGIC;
    CE : out STD_LOGIC;
    CF : out STD_LOGIC;
    CG : out STD_LOGIC;
    DP : out STD_LOGIC
  );
end SinGenerator6;

-- Каждый модуль ЦАП содержит два двухканальных ЦАП (т.е. всего 4 канала), но для повышения быстродействия в оба канала каждого ЦАП загружаются
-- одинаковые значения, в результате каждый модуль обеспечивает по 2 эффективных канала. Первому из них соответствует суффикс 1, 3, 5 и 7, а второму 2, 4, 6 и 8.

architecture ArcSinGenerator6 of SinGenerator6 is

-- Счётчик получения частот пользовательского интерфейса.
signal UserInterfaceCounter : STD_LOGIC_VECTOR ((UserInterfaceCtrWidth - 1) downto 0) := (others => '0'); -- Присваивание для удобства симуляции.
-- Признак достижения максимума для счётчика со сдвигом на такт.
signal UserInterfaceCounterOverflow : STD_LOGIC;

-- Буферы для сигналов переключателей.
signal SW0_Buf, SW1_Buf : STD_LOGIC;
-- Буферы для сигналов кнопок.
signal BTN0_Buf, BTN1_Buf : STD_LOGIC;
-- Счётчик формирователь задержки при обработке сигналов кнопки.
signal ButtonTimeOutCounter : STD_LOGIC_VECTOR ((ButtonTimeOutCtrWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.
-- Регистр пользовательского сдвига фазы.
signal UserPhaseReg : STD_LOGIC_VECTOR ((PhaseRegWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.
-- Регистр выбора генерируемой частоты и установки коэффициента пересчёта предделителя.
signal FrequencyNumberReg : STD_LOGIC_VECTOR ((FreqNumRegWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.
-- Регистр выбора формы генерируемого сигнала.
-- 0 - синус, 1 - прямоугольник, 2 - нарастающий пилообразный сигнал, 3 - спадающий пилообразный сигнал.
signal WaveformTypeReg : STD_LOGIC_VECTOR ((WaveformTypeRegWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.

-- Сигналы выбора отображаемого разряда.
signal Sel_0, Sel_1 : STD_LOGIC;

-- Отображаемый в текущий момент 16-ричный символ.
signal BinBus : STD_LOGIC_VECTOR (3 downto 0);

-- Счётчик делитель частоты генератора сигналов.
signal SigGenCounter : STD_LOGIC_VECTOR ((SigGenCtrWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.

-- Сигналы переполнения для счётчика делителя частоты генератора сигналов (деление на 20, 25, 32 и 40).
signal SigGenCtrOvf_20, SigGenCtrOvf_25, SigGenCtrOvf_32, SigGenCtrOvf_40 : STD_LOGIC;

-- Выбранный сигнал переполнения для счётчика делителя частоты генератора сигналов и 8 задержанных его копий.
signal SigGenCtrOvf, SigGenCtrOvf_1T, SigGenCtrOvf_2T, SigGenCtrOvf_3T, SigGenCtrOvf_4T, SigGenCtrOvf_5T, SigGenCtrOvf_6T, SigGenCtrOvf_7T, SigGenCtrOvf_8T : STD_LOGIC;

-- Аккумулятор фазы для сигнала с постоянной частотой.
signal RefPhaseCounter : STD_LOGIC_VECTOR ((PhaseRegWidth - 1) downto 0) := (others => '0'); -- Для удобства симуляции.

-- Входной регистр преобразователя фаза-амплитуда.
signal PhaseReg : STD_LOGIC_VECTOR ((PhaseRegWidth - 1) downto 0);

-- Выходной сигнал и регистр преобразователя фаза-амплитуда.
signal Sine, WaveformReg : STD_LOGIC_VECTOR ((AmpRegWidth - 1) downto 0);

-- Регистр преобразования прямого кода в дополнительный.
signal WaveformCorrReg : STD_LOGIC_VECTOR ((AmpRegWidth - 1) downto 0);

-- Буферы, в которых сохраняются результирующие значения сигналов.
signal Buffer_0, Buffer_45, Buffer_90, Buffer_180, Buffer_Usr : STD_LOGIC_VECTOR ((AmpRegWidth - 1) downto 0);

-- Сигналы управления DAC до стробирования.
signal DAC1357_Data, DAC12345678_nLE : STD_LOGIC;
signal DAC2_Data, DAC4_Data, DAC6_Data, DAC8_Data : STD_LOGIC;

-- Таблица отсчётов синуса.
component HSineTable is
  port (
    Binary : in STD_LOGIC_VECTOR (6 downto 0);
    Sine : out STD_LOGIC_VECTOR (6 downto 0)
  );
end component;

begin

-- ==================== Подраздел интерфейса пользователя. ====================

  -- Счётчик получения частот пользовательского интерфейса.
  -- Признак достижения максимума для счётчика со сдвигом на такт.
  -- Частоты используются для регенерации индикатора и опроса кнопок и переключателей.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      UserInterfaceCounter <= UserInterfaceCounter + 1;
      if (UserInterfaceCounter = (UserInterfaceCounter'Range => '1')) then
        UserInterfaceCounterOverflow <= '1';
      else
        UserInterfaceCounterOverflow <= '0';
      end if;
    end if;
  end process;

  -- Буферизация сигналов переключателей и кнопок,
  -- счётчик формирователь задержки при обработке сигналов кнопки,
  -- регистр выбора генерируемой частоты и он же регистр установки коэффициента пересчёта делителя частоты генератора сигналов,
  -- регистр пользовательского сдвига фазы,
  -- регистр выбора формы генерируемого сигнала.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (UserInterfaceCounterOverflow = '1') then
        --
        SW0_Buf <= SW0;
        SW1_Buf <= SW1;
        BTN0_Buf <= BTN0;
        BTN1_Buf <= BTN1;
        --
        if (BTN0_Buf = '0') and (BTN1_Buf = '1') then -- Кнопка BTN0 нажата, а BTN1 отжата.
          ButtonTimeOutCounter <= ButtonTimeOutCounter + 1;
          if (ButtonTimeOutCounter = (ButtonTimeOutCounter'Range => '1')) then
            if    (SW0_Buf = '0') and (SW1_Buf = '0') then -- SW0 в правом положении, SW1 в правом положении.
              UserPhaseReg <= UserPhaseReg + 1;
            elsif (SW0_Buf = '1') and (SW1_Buf = '0') then -- SW0 в левом положении, SW1 в правом положении.
              FrequencyNumberReg <= FrequencyNumberReg + 1;
            else                                           -- SW0 в произвольном положении, SW1 в левом положении.
              WaveformTypeReg <= WaveformTypeReg + 1;
            end if;
          end if;
        elsif (BTN0_Buf = '1') and (BTN1_Buf = '0') then -- Кнопка BTN0 отжата, а BTN1 нажата.
          ButtonTimeOutCounter <= ButtonTimeOutCounter + 1;
          if (ButtonTimeOutCounter = (ButtonTimeOutCounter'Range => '1')) then
            if    (SW0_Buf = '0') and (SW1_Buf = '0') then -- SW0 в правом положении, SW1 в правом положении.
              UserPhaseReg <= UserPhaseReg - 1;
            elsif (SW0_Buf = '1') and (SW1_Buf = '0') then -- SW0 в левом положении, SW1 в правом положении.
              FrequencyNumberReg <= FrequencyNumberReg - 1;
            else                                           -- SW0 в произвольном положении, SW1 в левом положении.
              WaveformTypeReg <= WaveformTypeReg - 1;
            end if;
          end if;
        else
          ButtonTimeOutCounter <= (others => '0');
        end if;
        --
      end if;
    end if;
  end process;

  -- Индикация на светодиодах.
  LD0 <= not (     UserInterfaceCounter (UserInterfaceCtrWidth - 1));
  LD1 <= not ((not UserInterfaceCounter (UserInterfaceCtrWidth - 1)) and      UserInterfaceCounter (UserInterfaceCtrWidth - 2));
  LD2 <= not ((not UserInterfaceCounter (UserInterfaceCtrWidth - 1)) and (not UserInterfaceCounter (UserInterfaceCtrWidth - 2)) and      UserInterfaceCounter (UserInterfaceCtrWidth - 3));
  LD3 <= not ((not UserInterfaceCounter (UserInterfaceCtrWidth - 1)) and (not UserInterfaceCounter (UserInterfaceCtrWidth - 2)) and (not UserInterfaceCounter (UserInterfaceCtrWidth - 3)) and UserInterfaceCounter (UserInterfaceCtrWidth - 4));

  -- Индикация на семисегментном индикаторе.

  -- Сигналы выбора активного разряда индикатора.
  Sel_0 <= UserInterfaceCounter (UserInterfaceCtrWidth - 2);
  Sel_1 <= UserInterfaceCounter (UserInterfaceCtrWidth - 1);

  -- Последовательный перебор анодов индикатора.
  Digit0 <= '0' when (Sel_1 = '0') and (Sel_0 = '0') else '1';
  Digit1 <= '0' when (Sel_1 = '0') and (Sel_0 = '1') else '1';
  Digit2 <= '0' when (Sel_1 = '1') and (Sel_0 = '0') else '1';
  Digit3 <= '0' when (Sel_1 = '1') and (Sel_0 = '1') else '1';

  -- Выбор одного 16-ричного символа для отображения на индикаторе.
  BinBus <= UserPhaseReg (3 downto 0) when (Sel_1 = '0') and (Sel_0 = '0') else
            UserPhaseReg (7) & UserPhaseReg (6) & UserPhaseReg (5) & UserPhaseReg (4) when (Sel_1 = '0') and (Sel_0 = '1') else
            FrequencyNumberReg when (Sel_1 = '1') and (Sel_0 = '0') else
            WaveformTypeReg (1) & WaveformTypeReg (0) & '0' & (not SW1_Buf);

  -- Получение кодов для семисегментного индикатора.
  process (BinBus)
  begin
    case (BinBus) is
      when "0000" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '1'; DP <= '1';
      when "0001" => CA <= '1'; CB <= '0'; CC <= '0'; CD <= '1'; CE <= '1'; CF <= '1'; CG <= '1'; DP <= '1';
      when "0010" => CA <= '0'; CB <= '0'; CC <= '1'; CD <= '0'; CE <= '0'; CF <= '1'; CG <= '0'; DP <= '1';
      when "0011" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '0'; CE <= '1'; CF <= '1'; CG <= '0'; DP <= '1';
      when "0100" => CA <= '1'; CB <= '0'; CC <= '0'; CD <= '1'; CE <= '1'; CF <= '0'; CG <= '0'; DP <= '1';
      when "0101" => CA <= '0'; CB <= '1'; CC <= '0'; CD <= '0'; CE <= '1'; CF <= '0'; CG <= '0'; DP <= '1';
      when "0110" => CA <= '0'; CB <= '1'; CC <= '0'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
      when "0111" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '1'; CE <= '1'; CF <= '1'; CG <= '1'; DP <= '1';
      when "1000" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
      when "1001" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '0'; CE <= '1'; CF <= '0'; CG <= '0'; DP <= '1';
      when "1010" => CA <= '0'; CB <= '0'; CC <= '0'; CD <= '1'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
      when "1011" => CA <= '1'; CB <= '1'; CC <= '0'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
      when "1100" => CA <= '0'; CB <= '1'; CC <= '1'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '1'; DP <= '1';
      when "1101" => CA <= '1'; CB <= '0'; CC <= '0'; CD <= '0'; CE <= '0'; CF <= '1'; CG <= '0'; DP <= '1';
      when "1110" => CA <= '0'; CB <= '1'; CC <= '1'; CD <= '0'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
      when others => CA <= '0'; CB <= '1'; CC <= '1'; CD <= '1'; CE <= '0'; CF <= '0'; CG <= '0'; DP <= '1';
    end case;
  end process;

-- ==================== Подраздел генератора сигналов. ====================

  -- Счётчик делитель частоты генератора сигналов. Используется для формирования 20/25/32/40-тактных циклов передачи данных в ЦАП.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (SigGenCtrOvf = '1') then
        SigGenCounter <= (others => '0');
      else
        SigGenCounter <= SigGenCounter + 1;
      end if;
    end if;
  end process;

  -- Признаки переполнения этого счётчика при делении на 20, 25, 32 и 40.
  SigGenCtrOvf_20 <= '1' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (19, SigGenCounter'length)) else '0';
  SigGenCtrOvf_25 <= '1' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (24, SigGenCounter'length)) else '0';
  SigGenCtrOvf_32 <= '1' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (31, SigGenCounter'length)) else '0';
  SigGenCtrOvf_40 <= '1' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (39, SigGenCounter'length)) else '0';

  -- Выбор активного коэффициента пересчёта.
  SigGenCtrOvf <= SigGenCtrOvf_20 when (FrequencyNumberReg (1) = '0') and (FrequencyNumberReg (0) = '0') else
                  SigGenCtrOvf_25 when (FrequencyNumberReg (1) = '0') and (FrequencyNumberReg (0) = '1') else
                  SigGenCtrOvf_32 when (FrequencyNumberReg (1) = '1') and (FrequencyNumberReg (0) = '0') else SigGenCtrOvf_40;

  -- Признак переполнения с задержкой на 1, 2, 3, 4, 5, 6, 7 и 8 тактов. Нужны для управления работой других узлов схемы.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      SigGenCtrOvf_1T <= SigGenCtrOvf;
      SigGenCtrOvf_2T <= SigGenCtrOvf_1T;
      SigGenCtrOvf_3T <= SigGenCtrOvf_2T;
      SigGenCtrOvf_4T <= SigGenCtrOvf_3T;
      SigGenCtrOvf_5T <= SigGenCtrOvf_4T;
      SigGenCtrOvf_6T <= SigGenCtrOvf_5T;
      SigGenCtrOvf_7T <= SigGenCtrOvf_6T;
      SigGenCtrOvf_8T <= SigGenCtrOvf_7T;
    end if;
  end process;

  -- Аккумулятор фазы. Предусмотрена генерация 4-х частот:
  -- 1 * FClock / (20(25, 32, 40) * 256),
  -- 2 * FClock / (20(25, 32, 40) * 256),
  -- 3 * FClock / (20(25, 32, 40) * 256),
  -- 4 * FClock / (20(25, 32, 40) * 256) и режим остановки.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (SigGenCtrOvf_1T = '1') and (SW1_Buf = '0') then
        if    (FrequencyNumberReg (FreqNumRegWidth - 1) = '0') and (FrequencyNumberReg (FreqNumRegWidth - 2) = '0') then
          RefPhaseCounter <= RefPhaseCounter + 1;
        elsif (FrequencyNumberReg (FreqNumRegWidth - 1) = '0') and (FrequencyNumberReg (FreqNumRegWidth - 2) = '1') then
          RefPhaseCounter <= RefPhaseCounter + 2;
        elsif (FrequencyNumberReg (FreqNumRegWidth - 1) = '1') and (FrequencyNumberReg (FreqNumRegWidth - 2) = '0') then
          RefPhaseCounter <= RefPhaseCounter + 3;
        else
          RefPhaseCounter <= RefPhaseCounter + 4;
        end if;
      end if;
    end if;
  end process;

  -- Входной регистр преобразователя фаза-амплитуда.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (SigGenCtrOvf_1T = '1') then
        PhaseReg <= RefPhaseCounter; -- Запись значения аккумулятора фазы.
      elsif (SigGenCtrOvf_2T = '1') then
        PhaseReg <= PhaseReg + x"20"; -- Увеличение значения фазы на восьмую часть периода. Т.е. на 45 градусов.
      elsif (SigGenCtrOvf_3T = '1') then
        PhaseReg <= PhaseReg + x"20"; -- Повторное увеличение значения фазы на восьмую часть периода. Т.е. если сразу после загрузки регистра был синус, здесь будет косинус.
      elsif (SigGenCtrOvf_4T = '1') then
        PhaseReg <= PhaseReg + x"40"; -- Увеличение значения фазы на четверть периода. Т.е. здесь будет синус со знаком минус.
      elsif (SigGenCtrOvf_5T = '1') then
        PhaseReg <= PhaseReg + x"80" + UserPhaseReg; -- Увеличение значения фазы на пол периода плюс пользовательский сдвиг фазы. Т.е. здесь будет синус с пользовательским сдвигом.
      end if;
    end if;
  end process;

  -- Преобразование фаза-амплитуда с помощью ПЗУ отсчётов синуса.
  Label_01 : HSineTable
    port map    (Binary => PhaseReg ((PhaseRegWidth - 2) downto 0), Sine => Sine ((AmpRegWidth - 2) downto 0));

  -- Старший разряд проходит без изменений, т.е. ниже получается число со знаком в прямом коде.
  Sine (AmpRegWidth - 1) <= PhaseReg (PhaseRegWidth - 1);

  -- Регистр первой ступени преобразования фаза-амплитуда (для синусоиды/прямоугольника здесь будет синус в прямом коде,
  -- для пилообразных сигналов - регистр фазы).
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (WaveformTypeReg (1) = '0') then
        WaveformReg <= Sine;
      else
        WaveformReg <= PhaseReg;
      end if;
    end if;
  end process;

  -- Регистр второй ступени преобразования фаза-амплитуда (для синусоиды здесь будет преобразования прямого кода в дополнительный,
  -- для прямоугольника все разряды приравниваются к старшему разряду,
  -- для пилообразных сигналов происходит либо сквозная передача фазы, либо передача фазы с инверсией).
  -- Преобразование выполняется за 1 такт.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (WaveformTypeReg (1) = '0') and (WaveformTypeReg (0) = '0') then -- Синус.
        if (WaveformReg (AmpRegWidth - 1) = '0') then
          WaveformCorrReg <= '0' & WaveformReg ((AmpRegWidth - 2) downto 0);
        else
          WaveformCorrReg <= not ('0' & WaveformReg ((AmpRegWidth - 2) downto 0)) + 1;
        end if;
      elsif (WaveformTypeReg (1) = '0') and (WaveformTypeReg (0) = '1') then -- Прямоугольник.
        if (WaveformReg (AmpRegWidth - 1) = '0') then
          WaveformCorrReg (AmpRegWidth - 1) <= '0';
          WaveformCorrReg ((AmpRegWidth - 2) downto 0) <= (others => '1');
        else
          WaveformCorrReg (AmpRegWidth - 1) <= '1';
          WaveformCorrReg ((AmpRegWidth - 2) downto 0) <= (others => '0');
        end if;
      elsif (WaveformTypeReg (1) = '1') and (WaveformTypeReg (0) = '0') then -- Нарастающий пилообразный сигнал.
        WaveformCorrReg <= WaveformReg;
      elsif (WaveformTypeReg (1) = '1') and (WaveformTypeReg (0) = '1') then -- Спадающий пилообразный сигнал.
        WaveformCorrReg <= not WaveformReg;
      end if;
    end if;
  end process;

  -- Выходные буферы.
  -- Здесь же производится конверсия дополнительного кода в straight binary инверсией старшего разряда, который необходим для ЦАП.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      if (SigGenCtrOvf_4T = '1') then
        Buffer_0 <= (not WaveformCorrReg (AmpRegWidth - 1)) & WaveformCorrReg ((AmpRegWidth - 2) downto 0); -- Синус (прямоугольник/пилообразный сигнал).
      end if;
      if (SigGenCtrOvf_5T = '1') then
        Buffer_45 <= (not WaveformCorrReg (AmpRegWidth - 1)) & WaveformCorrReg ((AmpRegWidth - 2) downto 0); -- Синус (...) со сдвигом на 45 градусов.
      end if;
      if (SigGenCtrOvf_6T = '1') then
        Buffer_90 <= (not WaveformCorrReg (AmpRegWidth - 1)) & WaveformCorrReg ((AmpRegWidth - 2) downto 0); -- Косинус (...).
      end if;
      if (SigGenCtrOvf_7T = '1') then
        Buffer_180 <= (not WaveformCorrReg (AmpRegWidth - 1)) & WaveformCorrReg ((AmpRegWidth - 2) downto 0); -- Синус (...) со знаком минус.
      end if;
      if (SigGenCtrOvf_8T = '1') then
        Buffer_Usr <= (not WaveformCorrReg (AmpRegWidth - 1)) & WaveformCorrReg ((AmpRegWidth - 2) downto 0); -- Синус (...) с пользовательским сдвигом.
      end if;
    end if;
  end process;

  -- Данные для ЦАП1, ЦАП3, ЦАП5, ЦАП7.
  DAC1357_Data <= '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (0, SigGenCounter'length)) else -- Бит nINT/EXT.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (1, SigGenCounter'length)) else -- Неиспользуемый бит.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (2, SigGenCounter'length)) else -- Бит LDAC.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (3, SigGenCounter'length)) else -- Бит PDB.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (4, SigGenCounter'length)) else -- Бит PDA.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (5, SigGenCounter'length)) else -- Бит nA/B.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (6, SigGenCounter'length)) else -- Бит CR1.
                  '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (7, SigGenCounter'length)) else -- Бит CR0.
                  Buffer_0 (7) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (8, SigGenCounter'length)) else
                  Buffer_0 (6) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (9, SigGenCounter'length)) else
                  Buffer_0 (5) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (10, SigGenCounter'length)) else
                  Buffer_0 (4) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (11, SigGenCounter'length)) else
                  Buffer_0 (3) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (12, SigGenCounter'length)) else
                  Buffer_0 (2) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (13, SigGenCounter'length)) else
                  Buffer_0 (1) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (14, SigGenCounter'length)) else
                  Buffer_0 (0) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (15, SigGenCounter'length)) else '0';

  -- Данные для ЦАП2.
  DAC2_Data <= '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (0, SigGenCounter'length)) else -- Бит nINT/EXT.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (1, SigGenCounter'length)) else -- Неиспользуемый бит.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (2, SigGenCounter'length)) else -- Бит LDAC.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (3, SigGenCounter'length)) else -- Бит PDB.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (4, SigGenCounter'length)) else -- Бит PDA.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (5, SigGenCounter'length)) else -- Бит nA/B.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (6, SigGenCounter'length)) else -- Бит CR1.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (7, SigGenCounter'length)) else -- Бит CR0.
               Buffer_45 (7) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (8, SigGenCounter'length)) else
               Buffer_45 (6) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (9, SigGenCounter'length)) else
               Buffer_45 (5) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (10, SigGenCounter'length)) else
               Buffer_45 (4) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (11, SigGenCounter'length)) else
               Buffer_45 (3) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (12, SigGenCounter'length)) else
               Buffer_45 (2) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (13, SigGenCounter'length)) else
               Buffer_45 (1) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (14, SigGenCounter'length)) else
               Buffer_45 (0) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (15, SigGenCounter'length)) else '0';

  -- Данные для ЦАП4.
  DAC4_Data <= '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (0, SigGenCounter'length)) else -- Бит nINT/EXT.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (1, SigGenCounter'length)) else -- Неиспользуемый бит.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (2, SigGenCounter'length)) else -- Бит LDAC.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (3, SigGenCounter'length)) else -- Бит PDB.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (4, SigGenCounter'length)) else -- Бит PDA.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (5, SigGenCounter'length)) else -- Бит nA/B.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (6, SigGenCounter'length)) else -- Бит CR1.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (7, SigGenCounter'length)) else -- Бит CR0.
               Buffer_90 (7) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (8, SigGenCounter'length)) else
               Buffer_90 (6) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (9, SigGenCounter'length)) else
               Buffer_90 (5) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (10, SigGenCounter'length)) else
               Buffer_90 (4) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (11, SigGenCounter'length)) else
               Buffer_90 (3) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (12, SigGenCounter'length)) else
               Buffer_90 (2) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (13, SigGenCounter'length)) else
               Buffer_90 (1) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (14, SigGenCounter'length)) else
               Buffer_90 (0) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (15, SigGenCounter'length)) else '0';

  -- Данные для ЦАП6.
  DAC6_Data <= '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (0, SigGenCounter'length)) else -- Бит nINT/EXT.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (1, SigGenCounter'length)) else -- Неиспользуемый бит.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (2, SigGenCounter'length)) else -- Бит LDAC.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (3, SigGenCounter'length)) else -- Бит PDB.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (4, SigGenCounter'length)) else -- Бит PDA.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (5, SigGenCounter'length)) else -- Бит nA/B.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (6, SigGenCounter'length)) else -- Бит CR1.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (7, SigGenCounter'length)) else -- Бит CR0.
               Buffer_180 (7) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (8, SigGenCounter'length)) else
               Buffer_180 (6) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (9, SigGenCounter'length)) else
               Buffer_180 (5) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (10, SigGenCounter'length)) else
               Buffer_180 (4) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (11, SigGenCounter'length)) else
               Buffer_180 (3) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (12, SigGenCounter'length)) else
               Buffer_180 (2) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (13, SigGenCounter'length)) else
               Buffer_180 (1) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (14, SigGenCounter'length)) else
               Buffer_180 (0) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (15, SigGenCounter'length)) else '0';

  -- Данные для ЦАП8.
  DAC8_Data <= '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (0, SigGenCounter'length)) else -- Бит nINT/EXT.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (1, SigGenCounter'length)) else -- Неиспользуемый бит.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (2, SigGenCounter'length)) else -- Бит LDAC.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (3, SigGenCounter'length)) else -- Бит PDB.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (4, SigGenCounter'length)) else -- Бит PDA.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (5, SigGenCounter'length)) else -- Бит nA/B.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (6, SigGenCounter'length)) else -- Бит CR1.
               '0' when (SigGenCounter = CONV_STD_LOGIC_VECTOR (7, SigGenCounter'length)) else -- Бит CR0.
               Buffer_Usr (7) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (8, SigGenCounter'length)) else
               Buffer_Usr (6) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (9, SigGenCounter'length)) else
               Buffer_Usr (5) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (10, SigGenCounter'length)) else
               Buffer_Usr (4) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (11, SigGenCounter'length)) else
               Buffer_Usr (3) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (12, SigGenCounter'length)) else
               Buffer_Usr (2) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (13, SigGenCounter'length)) else
               Buffer_Usr (1) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (14, SigGenCounter'length)) else
               Buffer_Usr (0) when (SigGenCounter = CONV_STD_LOGIC_VECTOR (15, SigGenCounter'length)) else '0';

  -- Сигнал разрешения записи данных в ЦАП.
  -- Этот сигнал можно получить применив операцию ИЛИ к двум старшим разрядам счётчика делителя частоты генератора сигналов.
  -- Первые 16 тактов этот сигнал имеет низкое значение, последующие 4/9/16/24 такта - высокое.
  DAC12345678_nLE <= SigGenCounter (SigGenCtrWidth - 1) or SigGenCounter (SigGenCtrWidth - 2);

  -- Стробирование сигналов Data и LE ЦАП.
  process (Clk)
  begin
    if RISING_EDGE (Clk) then
      -- Сигналы к первому модулю ЦАП.
      DAC1_Data_R <= DAC1357_Data;
      DAC2_Data_R <= DAC2_Data;
      DAC12_nLE_R <= DAC12345678_nLE;
      -- Их копия.
      DAC1_Data_R_Copy <= DAC1357_Data;
      DAC2_Data_R_Copy <= DAC2_Data;
      DAC12_nLE_R_Copy <= DAC12345678_nLE;
      -- Сигналы ко второму модулю ЦАП.
      DAC3_Data_R <= DAC1357_Data;
      DAC4_Data_R <= DAC4_Data;
      DAC34_nLE_R <= DAC12345678_nLE;
      -- Их копия.
      DAC3_Data_R_Copy <= DAC1357_Data;
      DAC4_Data_R_Copy <= DAC4_Data;
      DAC34_nLE_R_Copy <= DAC12345678_nLE;
      -- Сигналы к третьему модулю ЦАП.
      DAC5_Data_R <= DAC1357_Data;
      DAC6_Data_R <= DAC6_Data;
      DAC56_nLE_R <= DAC12345678_nLE;
      -- Их копия.
      DAC5_Data_R_Copy <= DAC1357_Data;
      DAC6_Data_R_Copy <= DAC6_Data;
      DAC56_nLE_R_Copy <= DAC12345678_nLE;
      -- Сигналы к четвёртому модулю ЦАП.
      DAC7_Data_R <= DAC1357_Data;
      DAC8_Data_R <= DAC8_Data;
      DAC78_nLE_R <= DAC12345678_nLE;
      -- Их копия.
      DAC7_Data_R_Copy <= DAC1357_Data;
      DAC8_Data_R_Copy <= DAC8_Data;
      DAC78_nLE_R_Copy <= DAC12345678_nLE;
    end if;
  end process;

  -- Тактовый сигнал для ЦАП.
  DAC12_Clk <= not Clk;
  DAC12_Clk_Copy <= not Clk;
  DAC34_Clk <= not Clk;
  DAC34_Clk_Copy <= not Clk;
  DAC56_Clk <= not Clk;
  DAC56_Clk_Copy <= not Clk;
  DAC78_Clk <= not Clk;
  DAC78_Clk_Copy <= not Clk;

end ArcSinGenerator6;
