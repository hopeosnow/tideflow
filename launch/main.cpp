//by hopeos
//tideflow DE project
//build with love in Fuzhou 2026/11/22
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include<QUrl>
#include<QDebug>
#include<vector>
#include<fstream>
#include<filesystem>
#include<QSettings>
#include<QString>
struct app_info
{
    QString name;
    QString exec;
    QString icon;
    QString keywords;
    QString category;
    bool terminal = false;
    QString comment;

};
class pro_desktop{
    public:

        bool parsefile(const std::string &filepath)
        {
            QSettings settings(QString::fromStdString(filepath),QSettings::IniFormat);
            app_info info;
            if (settings.status()!=QSettings::NoError)return false;//检查状态
            if (settings.value("Desktop Entry/NoDisplay",false).toBool())
            {
                return false;
            }
            settings.beginGroup("Desktop Entry");
            //解析各项字段，因为desktop是ini文件（ai教的）
            info.name=settings.value("Name").toString();
            info.exec=settings.value("Exec").toString();
            info.icon=settings.value("Icon").toString();
            info.keywords=settings.value("Keywords").toString();
            info.terminal=settings.value("Terminal").toBool();
            info.comment=settings.value("Comment").toString();
            info.category=settings.value("Category").toString();
            settings.endGroup();
            applist.push_back(info);
            return true;//正常退出


        }
        //TODO 实现扫描文件列表

        bool scandir(){
            std::filesystem::path p;
            std::string dir ="/usr/share/applications";
            if (dir.empty() || !std::filesystem::is_directory(dir)) return false;
            for (const auto & entry : std::filesystem::directory_iterator(dir))
            {
                if (!entry.is_regular_file())
                {
                    continue;
                }
                if (entry.path().extension()!=".desktop")continue;
                std::string filepath = entry.path().string();
                filelist.push_back(filepath);
                parsefile(filepath);
            }
            return true;
        }


protected:
    std::vector<app_info> applist;
    std::vector<std::string> filelist;



};
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QCoreApplication::setApplicationName("Tideflow launch");
    QCoreApplication::setApplicationVersion("1.0.0");
    QCoreApplication::setOrganizationName("Tideflow");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,&app,[](){QCoreApplication::exit(-1);},Qt::QueuedConnection);
    engine.loadFromModule("Tideflow", "Main");

    return app.exec();
}