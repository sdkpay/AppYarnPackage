import dropbox
import os
import click
import telebot

# Token Generated from dropbox
DBX_TOKEN = 'sl.BgvMTpj2vDX4ZHNKMHs8MhRi50lhgJ167TiFbXLrt1HhHUwuX16WP-eM9avehHfuPrsME4LwWSmb30hkDv99Ur1GY2i-EhXPa7XADtVUgQXFRoCeaXKdSDAY1auSnTMgIsf-zQBkt3jw'

TG_TOKEN = "5672018524:AAFfFSjB5GodidvwS2rtESvxf0SK4_6VMX4"

CHAT_ID = -866042957


class TransferData:
    def __init__(self, access_token):
        self.access_token = access_token

    def upload_file(self, dbx, file_from, file_to):
        with open(file_from, 'rb') as f:
            dbx.files_upload(f.read(), file_to)


def upload_files(dbx, version, mob_os, path):
    transferData = TransferData(DBX_TOKEN)

    file_from = path
    file_to = '/%s/%s/%s' % (mob_os, version, os.path.basename(os.path.normpath(path)))
    try:
        transferData.upload_file(dbx, file_from, file_to)
        print('🌐Upload file successfully to path', file_to)
        get_link(dbx, file_to)
    except Exception as e:
        print(str(e))


def get_link(dbx, path):
    try:
        link = dbx.files_get_temporary_link(path).link
        print("🔗Link:", link)
    except Exception as e:
        print(str(e))


def connect_to_dropbox():
    try:
        dbx = dropbox.Dropbox(DBX_TOKEN)
        print('✅Connected to Dropbox successfully')
    except Exception as e:
        print(str(e))
    return dbx


def connect_to_tg():
    try:
        bot = telebot.TeleBot(TG_TOKEN)
        print('✅Connected to tg successfully')
    except Exception as e:
        print(str(e))
    return bot


def list_files(dbx, path):
    folder_path = '/%s' % path

    try:
        files = dbx.files_list_folder(folder_path).entries
        print("Platform:", path)
        for file in files:
            metadata = {
                'name': file.name,
                'path_display': file.path_display
            }
            print(metadata)

    except Exception as e:
        print('Error getting list of files from Dropbox: ' + str(e))


def send_notification_to_group(text):
    bot = connect_to_tg()
    bot.send_message(CHAT_ID, text)

@click.command()
@click.argument('method')
@click.option(
    '--path', '-a',
    help='Путь к файлу',
)
@click.option(
    '--mob-os', '-a',
    help='OS - iOS или android',
)
@click.option(
    '--v', '-a',
    help='Версия приложения',
)
@click.option(
    '--notify', '-a',
    help='Нужно ли уведомить группу',
)
def main(method, mob_os, path, v):
    """
    Утилита для выгрузки файлов с SPay SDK\n
    1. load - метод для загрузки файла на дропбокс\n
    2. v - Показывает все доступные версии\n
    3. link - Отдает ссылку по пути проекта\n
    """
    dbx = connect_to_dropbox()
    if method == "load":
        if mob_os == "android" and mob_os == "iOS":
            upload_files(dbx, v, mob_os, path)
        else:
            print("❌ Неверное название os, смотри --help")
    elif method == "v":
        if mob_os == "android" and mob_os == "iOS":
            list_files(dbx, mob_os)
        else:
            print("❌ Неверное название os, смотри --help")
    elif method == "link":
        get_link(dbx, path)
    elif method == "notify":
        print("")
    else:
        print("❌ Неверное название метода, смотри --help")


if __name__ == "__main__":
    main()
