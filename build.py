import click
import subprocess

def loadToDropBox():
 print("🚀 Run build.sh")

def runBuildSDK():
 print("🚀 Run build.sh")
 subprocess.call(['sh', './build.sh'])

def buildProject():
 print("🚀 Run makeProject.sh")
 subprocess.call(['sh', './makeProject.sh'])

def archiveTest():
 print("🚀 Run arcApp.sh")
 subprocess.call(['sh', './arcApp.sh'])

@click.command()
@click.argument('command')
def main(command):
 """
Утилита для работы с SPay SDK\n
Список команд:\n
 1. make_sdk - Собирает артефакт, готовый к передаче мерчу\n
 2. make_project - Собирает файл project и генерирует ресурсы\n
 3. make_ipa - Собирает .ipa файл тестового приложения с сдк
 4. load_dropbox - Отправляет файлы в дропбокс
 """
 if command == "make_sdk":
  runBuildSDK()
 elif command == "make_project":
  buildProject()
 elif command == "make_ipa":
  archiveTest()
 elif command == "load_dropbox":
  loadToDropBox()
 else:
  print("❌ Неверная команда, запусти build.py --help")

if __name__ == "__main__":
        main()

