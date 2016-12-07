//#include "mainwindow.h"
#include <QApplication>
#include <QMessageBox>
#include <QTextStream>
#include <QString>
#include <QStringList>
#include <QDebug>
//#include <QIcon>

int main(int argc, char *argv[])
{
    QApplication the_app(argc, argv);

    //trying to get the arguments into a list
    QStringList cmdline_args = QCoreApplication::arguments();
    QString title , query, bouton, icon;
    int select = 0;
    QMessageBox::Icon icondlg = QMessageBox::NoIcon;
    QTextStream out(stdout);
    QMessageBox::StandardButtons StandardButtonint=0x00;

    for (int i = 1; i < cmdline_args.size(); ++i){
        if ( cmdline_args.at(i) == "-T" || cmdline_args.at(i) == "-t"){
            select = 1;
            continue;
        }else
        {
            if(cmdline_args.at(i) == "-q" || cmdline_args.at(i) == "-Q"){
                select = 2;
                continue;
            }
            else{
                if (cmdline_args.at(i) == "-b" || cmdline_args.at(i) == "-B"){
                    select = 3;
                    continue;
                }
                else{
                    if (cmdline_args.at(i) == "-i" || cmdline_args.at(i) == "-I"){
                        select = 4;
                        continue;
                    }
                }
            }
        }
        switch (select){
            case 1 : title = cmdline_args.at(i); break;
            case 2 : query = cmdline_args.at(i); break;
            case 3 : bouton = cmdline_args.at(i); break;
            case 4 : icon =  cmdline_args.at(i); break;
        }
  }
        //qDebug() <<  bouton;
        // creation de la liste des boutons.
        if (bouton == ""){
            bouton="yes,no";
        }

        QMessageBox msgBox;

        QStringList listbouton = bouton.split(",");
        for (int i = 0; i < listbouton.size(); ++i){
            if ( listbouton.at(i).toLower()== "yes" ){
                StandardButtonint |= QMessageBox::Yes;
                continue;
            }
            if (listbouton.at(i).toLower() == "no" ){
                StandardButtonint |= QMessageBox::No;
                continue;
            }
            if (listbouton.at(i).toLower() == "abort" ){
                StandardButtonint |= QMessageBox::Abort;
                continue;
            }
            if ( listbouton.at(i).toLower() == "retry" ){
                StandardButtonint |= QMessageBox::Retry;
                continue;
            }
            if ( listbouton.at(i).toLower() == "ignore" ){
                StandardButtonint |= QMessageBox::Ignore;
                continue;
            }
            if ( listbouton.at(i).toLower() == "open" ){
                StandardButtonint |= QMessageBox::Open;
                continue;
            }
            if ( listbouton.at(i).toLower() == "save" ){
                StandardButtonint |= QMessageBox::Save;
                continue;
            }
            if ( listbouton.at(i).toLower() == "cancel" ){
                StandardButtonint |= QMessageBox::Cancel;
                continue;
            }
            if ( listbouton.at(i).toLower() == "close" ){
                StandardButtonint |= QMessageBox::Close;
                continue;
            }
            if ( listbouton.at(i).toLower() == "discard" ){
                StandardButtonint |= QMessageBox::Discard;
                continue;
            }
            if ( listbouton.at(i).toLower() == "apply" ){
                StandardButtonint |= QMessageBox::Apply;
                continue;
            }
            if ( listbouton.at(i).toLower() == "reset" ){
                StandardButtonint |= QMessageBox::Reset;
                continue;
            }
            if ( listbouton.at(i).toLower() == "restoreDefaults" ){
                StandardButtonint |= QMessageBox::RestoreDefaults;
                continue;
            }
            if ( listbouton.at(i).toLower() == "ok" ){
                StandardButtonint |= QMessageBox::Ok;
                continue;
            }
        }

        if ( icon.toLower() == "information")   icondlg = QMessageBox::Information;
        if ( icon.toLower() == "question")      icondlg = QMessageBox::Question;
        if ( icon.toLower() == "warning")       icondlg = QMessageBox::Warning;
        if ( icon.toLower() == "critical")      icondlg = QMessageBox::Critical;
       msgBox.setText(title);
       msgBox.setInformativeText(query);//"Retry request after 3 hours"
       msgBox.setStandardButtons(StandardButtonint);
       msgBox.setIcon(icondlg);
        //msgBox.setDefaultButton(QMessageBox::Retry);
       int ret =  msgBox.exec();
       QString  str;
       switch (ret) {
                    case QMessageBox::Ok:
                        str="ok";
                        break;
                    case QMessageBox::Yes:
                        str="yes";
                        break;
                    case QMessageBox::No:
                        str="no";
                        break;
                    case QMessageBox::Abort:
                        str="abort";
                        break;
                    case QMessageBox::Retry:
                        str="retry";
                        break;
                    case QMessageBox::Ignore:
                        str="ignore";
                        break;
                    case QMessageBox::Open:
                        str="open";
                        break;
                    case QMessageBox::Save:
                        str="save";
                        break;
                    case QMessageBox::Cancel:
                        str="cancel";
                        break;
                    case QMessageBox::Close:
                        str="close";
                        break;
                    case QMessageBox::Discard:
                        str="discard";
                        break;
                    case QMessageBox::Apply:
                        str="apply";
                        break;
                    case QMessageBox::Reset:
                        str="reset";
                        break;
                    case QMessageBox::RestoreDefaults:
                        str="restoreDefaults";
                        break;
       }

       out << str << endl;
       return 0;
}
