import click
import subprocess

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
 1. makeSDK - Собирает артефакт, готовый к передаче мерчу\n
 2. makeProject - Собирает файл project и генерирует ресурсы\n
 3. archiveTest - Собирает .ipa файл тестового приложения с сдк
 """
 if command == "makeSDK":
  runBuildSDK()
 elif command == "makeProject":
  buildProject()
 elif command == "archiveTest":
  archiveTest()
 else:
  print("❌ Неверная команда, запусти build.py --help")

if __name__ == "__main__":
        main()

