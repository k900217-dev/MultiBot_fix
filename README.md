# About MultiBot_fix
由于该插件github上的作者已经一年多没有更新，插件已经不适配WLK335 2026.10月份以后编译的版本，有诸多问题，因此我根据playerbots 2026.10.16编译版本的源码重新修复该插件，具体如下（目前我还在筹备英文适配版本）：

更新日志

2026.11.18

1、修复了原插件按钮行上方区域，若干透明遮盖层造成的操作遮挡问题。

2、参看源码，修复了诸多按钮名称以及描述的翻译错误。并在一些容易造成误解的按钮中，增加了相应描述。

3、按钮被点中时的视觉呈现更加明显。

4、开关某个按钮时，按钮会先被压暗，1.5S后再重新显示，这样开关才反映了真实状态。原来由于响应时间问题，开关状态经常错误呈现。

*5、现在会根据职业、天赋，自动反映初始默认策略（每个职业不同天赋都有一套默认策略，当你修改后，时间长了可能会忘记初始策略是什么）。默认策略右上方有一个绿点。
本功能需要你在第一次使用插件时，为每个机器人输入初始天赋，按住CTRL左键点击该机器人对应控制按钮即可。之后切换天赋时，变量会自动更改，无需再手动参与。
6、修复了离线机器人对应按钮显示大问号的问题。

7、现在机器人对应控制按钮，鼠标悬浮能看到它的职业和天赋。

8、插件最有侧有一个被隐藏起来的书本按钮，这个按钮原来有一些BUG，所以被藏起来了。现在修复并加强了该按钮的功能和提示，作用是循环切换天赋和对应的装备，并可以一键切换篮/紫装（需要playerbots.conf中AutoGearQualityLimit至少为4），详情见按钮说明项。

9、修复了队伍与名单的刷新、排序、错位问题。

10、参看源码，修复了若干按钮的错误命令；去除了若干完全失效按钮（插件版本太老，命令与新端不匹配），但保留了其中一些失效按钮只加了描述提醒（可能在将来的playerbots会有变动，待观察）。

11、修复了策略中背包、技能书、天赋的？？显示问题。

Since the original author of this plugin on GitHub has not updated it for more than a year, the plugin is no longer compatible with WLK335 builds compiled after October 2026, resulting in many issues. Therefore, based on the playerbots source code from the 2026.10.16 build, I have re‑worked and fixed the plugin. Details are as follows (I am currently preparing an English‑adapted version):

Update Log

2026.11.18
1. Fixed the issue where several transparent overlay layers above the original plugin’s button rows caused interaction obstruction.
2. After reviewing the source code, corrected numerous translation errors in button names and descriptions. Additional explanations were added to buttons that could easily cause misunderstanding.
3. Improved the visual feedback when a button is clicked, making the state more noticeable.
4. When toggling a button, it will now dim first and reappear after 1.5 seconds, accurately reflecting the real toggle state. Previously, due to response timing issues, toggle states were often displayed incorrectly.
5. The plugin now automatically reflects the initial default strategy based on class and talent specialization (each class and spec has its own default strategy, which you may forget after modifying it for a long time). A green dot appears at the top‑right corner of the default strategy.
    This feature requires you to input the initial talent specialization for each bot the first time you use the plugin. Hold CTRL + Left‑Click on the bot’s control button to set it. After that, switching talents will automatically update the variable without further manual input.
6. Fixed the issue where offline bots displayed a large question mark on their corresponding buttons.
7. Bot control buttons now show the bot’s class and talent specialization when hovered with the mouse.
8. The plugin contains a hidden book‑shaped button on the far right. It originally had several bugs, so it was hidden. Now it has been fixed and enhanced. Its function is to cycle through talent specializations and their corresponding gear sets, and it can switch between blue/purple gear with one click (requires AutoGearQualityLimit in playerbots.conf to be at least 4). See the button description for details.
9. Fixed issues with refreshing, sorting, and misalignment in the team and list displays.
10. After reviewing the source code, corrected several incorrect button commands; removed several completely non‑functional buttons (the plugin was too old and commands no longer matched the new core). Some non‑functional buttons were kept but now include descriptive warnings (future versions of playerbots may change, so they are kept for observation).
11. Fixed the “??” display issues in strategies related to bags, spellbooks, and talents.

# MultiBot
User interface for AzerothCore-Module "Playerbot" by Liyunfan1223.<br>
Tested with American and German 3.3.5 Wotlk-Client.
# Installation
Simply place the files in a folder called "MultiBot" in your World of Warcraft AddOns directory.<br>
Example: "C:\WorldOfWarcraft\Interface\AddOns\MultiBot"
# Use
Start World of Warcraft and enter "/multibot" or "/mbot" or "/mb" in the chat.
# Current Status
<table>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-00-Start.png"></td>
    <td>
      This Picture shows the default MultiBot-Interface after start.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-00-Main-Control.png"></td>
    <td>
      The horizontal Buttonbar is the Main-Control.
      Commands from the Main-Control go to all bots in a Group or Raid.
      Differences in functionality are commented on in the tooltips.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-00-Playerbots.png"></td>
    <td>
      The vertical Buttonbar is the Playerbot-Selection.
      Here you will find the Characters of your Account.
      There is a button for each Character.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-00-Character-Info.png"></td>
    <td>
      The Tooltip of a Character-Button shows you the Class and Name of the Character.
      This should allow you to identify your characters.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Playerbot-Online.png"></td>
    <td>
      With a Left-Click you can load your Character and have him automatically added to the Party or Raid.
      The horizontal Buttonbar that appears is the Playerbot-Control.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Combat-Behaviour.png"></td>
    <td>
      You can use the Buttons on the left to adjust the Combat-Behavior of your Playerbot.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Summon.png"></td>
    <td>
      With the first Button on the right you can summon your Playerbot.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Group-And-Ungroup.png"></td>
    <td>
      With the second Button on the right you can add or dismiss your Playerbot from the Party or Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Non-Combat-Behaviour.png"></td>
    <td>
      With the next three the Buttons you can adjust the Non-Combat-Behavior of your Playerbot.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-01-Inventory.png"></td>
    <td>
      The last button on the right opens the Inventory of the Playerbot.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-02-Inspect-And-Inventory.png"></td>
    <td>
      A Left-Click on the Inventory-Button opens the Inspect- and Inventory-Window of your Playerbot.
      Notice: The Inspect-Window only will be open if the Playerbot is in reach.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-03-Sell-Mode.png"></td>
    <td>
      The Inventory will automatically open in Sell-Mode.
      In the Sell-Mode a left click on a Item will sell it.
      Notice: You must have a Merchent as Target.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-03-Equip-Mode.png"></td>
    <td>
      With this Button you can switch to the Equip-Mode.
      In the Equip-Mode a left click on a Item will equip it.
      Notice: Only works with Equipment.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-03-Use-Mode.png"></td>
    <td>
      With this Button you can switch to the Use-Mode.
      In the Use-Mode a left click on a Item will use it.
      Notice: Only works with usable Items.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-03-Destroy-Mode.png"></td>
    <td>
      With this Button you can switch to the Destroy-Mode.
      In the Destroy-Mode a left click on a Item will destroy it.
      Important: There is no security Quest and it will work with every Item.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-03-View-Mode.png"></td>
    <td>
      Items can be viewed regardless of the selected Mode.
      Means: View-Mode is always active.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-04-Hide-Playerbot-Control.png"></td>
    <td>
      With a left click on the Character-Button you can hide and show the Playerbot-Control.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-05-Hide-Playerbots.png"></td>
    <td>
      With a left click on the left Scroll-Button you can hide and show the Playerbots.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-06-Show-Friendbots.png"></td>
    <td>
      With a left click on the right Scroll-Button you can hide and show the Friendbots.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-06-Firendbots.png"></td>
    <td>
      The vertical Buttonbar is the Friend-Selection.
      Here you will find the Characters of your Friendlist.
      There are max 10 Buttons visible.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-06-Browse-Friendbots.png"></td>
    <td>
      With this Button you could browse throu your Friendlist.
      Each click will show the next 10 Characters.
      If you reach the End it starts from the Beginning.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-07-Filter-Selection.png"></td>
    <td>
      You can limit the Selection to make it easier to find the wished Friendbot.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-07-Filter-By-Classes.png"></td>
    <td>
      Simply press one of these Filter-Buttons to narrow down the Selection.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-08-No-Browse-Button.png"></td>
    <td>
      As you can see, the browse button has disappeared.
      This is because the Filter reduced the Selection to less than 10 Friendbots.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-08-Shows-Filter.png"></td>
    <td>
      The filter shows you the current limitation.
      In this example, we filtered to Warrior.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-08-Friendbot-Button.png"></td>
    <td>
      This button is the result of our filter.
      The functionality is almost identical to that of the Playerbots.
      Therefore we save ourselves a further explanation.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Tank-Attack.png"></td>
    <td>
      This is the Tank-Attack-Button.
      A left click on the Button let all Tanks attack you Target.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Actionbar-Attack.png"></td>
    <td>
      This is the Attack-Actionbar.
      A left click on the Button executes the selected Action.
      A right click on the Button will show and hide the Optional-Actions.
      To replace the selected Action, right click a Optional-Action.
      To execute a Optional-Action, left click it.
      The default Action is "All attack my target".
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Modebar.png"></td>
    <td>
      This is the Modebar.
      A left click on the Button enables and disables the selected Mode.
      A right click on the Button will show and hide the Mode-Selection.
      To select another Mode, left click the Mode-Option.
      The Mode will activated by selection.
      The default Mode-Toggle is "passive".
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Stay-Follow.png"></td>
    <td>
      This is the Stay-Follow-Toggle-Button.
      A left click on the Button sends the Stay-Command to the Party or Raid.
      Another left click on the Button sends the Follow-Command to the Party or Raid.
      The Icon will show the current State.
      The default State is "Follow".
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Actionbar-Flee.png"></td>
    <td>
      This is the Flee-Actionbar.
      A left click on the Button executes the selected Action.
      A right click on the Button will show and hide the Optional-Actions.
      To replace the selected Action, right click a Optional-Action.
      To execute a Optional-Action, left click it.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Formation.png"></td>
    <td>
      This is the Formation-Selector.
      A left click on the Button will show and hide the Options.
      A left click on the Option-Button will send the corresponding Formation-Command to the Party or Raid.
      A right click on the Button will ask the Party or Raid for the current Formation.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Beastmaster.png"></td>
    <td>
      This is the Beastmaster-Control.
      A left click on the Button will show and hide the Actions.
      A left click on the Action will send the corresponding Command to your Target, Party or Raid.
      It supports the "mod-beastmaster"-Module of the Azerothcore.
      These Buttons work with Target, Group and Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Control.png"></td>
    <td>
      This is the MultiBot-Control.
      A left click on the Button will show and hide the Controls.
      Here you will find the "reset", "reset botAI" and "naxx"-Commands for your Bots.
      These Buttons works with Target, Group and Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Drink.png"></td>
    <td>
      This Button will send the "drink"-Command to the Party or Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Release.png"></td>
    <td>
      This Button will send the "release"-Command to the Party or Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Revive.png"></td>
    <td>
      This Button will send the "revive"-Command to the Party or Raid.
    </td>
  </tr>
  <tr>
    <td><img src="https://github.com/Macx-Lio/MultiBot/blob/main/Screenshots/Handout-09-Summon.png"></td>
    <td>
      This Button will summon all active Friend- and Playerbots.
    </td>
  </tr>
</table>

# Comming soon
Currently i am working on the Group- and Raid-Controls.

# Currently not supported
QUEST
