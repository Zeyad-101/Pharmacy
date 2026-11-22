// El file da mas2ool 3an tashgheel el program: y3mel load lel data, w ywasal kol el managers ba3d, w y3mel el admin awel mara.
// Owner: Abdelrahman
// GUI: Abdelrhman (GUI) - el program dlwa2ty by3mel el GUI, we "--selftest" bey3mel el summary el adeem.
#include <QCoreApplication>
#include <QGuiApplication>
#include <QImage>
#include <QPainter>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QSharedPointer>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QString>
#include <QStringList>
#include <QTextStream>
#include <QTimer>
#include <QVariant>

#include "AppController.h"

using namespace pharmacy;

namespace {

bool hasArgument(int argc, char* argv[], const char* name)
{
    for (int i = 1; i < argc; ++i) {
        if (QString::fromLocal8Bit(argv[i]) == QLatin1String(name)) {
            return true;
        }
    }
    return false;
}

// The old console program, kept exactly as it was (run with --selftest)
int runSelfTest(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream out(stdout);
    QTextStream err(stderr);

    // The Data folder path comes from CMake (DATA_DIR)
    const QString dataDir = QStringLiteral(DATA_DIR);

    AppController controller(dataDir);
    QString error;
    bool adminCreated = false;
    if (!controller.initialize(&error, &adminCreated)) {
        err << "Error: " << error << Qt::endl;
        return 1;
    }
    if (adminCreated) {
        out << "Admin account created (username: admin)" << Qt::endl;
    }

    // Short startup summary
    out << "SmartPharmacy backend is ready" << Qt::endl;
    out << "Data folder: " << dataDir << Qt::endl;
    out << "Products: " << controller.productCount() << Qt::endl;
    out << "Users: " << controller.userCount() << Qt::endl;
    out << "Promo codes: " << controller.promoCodeCount() << Qt::endl;
    out << "Orders: " << controller.orderCount() << Qt::endl;

    return 0;
}

}

int main(int argc, char* argv[])
{
    if (hasArgument(argc, argv, "--selftest")) {
        return runSelfTest(argc, argv);
    }

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Basic"));
    QTextStream err(stderr);

    AppController controller(QStringLiteral(DATA_DIR));
    QString error;
    bool adminCreated = false;
    if (!controller.initialize(&error, &adminCreated)) {
        err << "Error: " << error << Qt::endl;
        return 1;
    }
    AppController::setInstance(&controller);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     []() { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("PharmaCare", "Main");
    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    // --shot <page> <file.png>: used only to verify the screens (opens the page, saves it, quits)
    const QStringList args = QCoreApplication::arguments();
    const int shotIndex = args.indexOf(QStringLiteral("--shot"));
    if (shotIndex != -1) {
        if (shotIndex + 2 >= args.size()) {
            err << "Usage: SmartPharmacy --shot <page> <file.png>" << Qt::endl;
            return 1;
        }
        const QString page = args.at(shotIndex + 1);
        const QString file = args.at(shotIndex + 2);
        QQuickWindow* window = qobject_cast<QQuickWindow*>(engine.rootObjects().constFirst());
        if (!window) {
            return 1;
        }
        QMetaObject::invokeMethod(window, "prepareShot", Q_ARG(QVariant, QVariant(page)));

        // Give the page time to lay out and load its images, then save it and quit
        QTimer::singleShot(2500, window, [window, file]() {
            QVariant overlay;
            QMetaObject::invokeMethod(window, "isOverlayShot", Q_RETURN_ARG(QVariant, overlay));
            if (overlay.toBool()) {
                // Overlays (drawer, quick view, search): the visible window
                const bool saved = window->grabWindow().save(file);
                QCoreApplication::exit(saved ? 0 : 1);
                return;
            }
            // Full pages are taller than the screen, so the header and the whole page are grabbed
            // separately at 1x (the size of the design boards) and stacked into one image
            QQuickItem* header = window->findChild<QQuickItem*>(QStringLiteral("shotHeader"));
            QQuickItem* pageItem = window->findChild<QQuickItem*>(QStringLiteral("shotPage"));
            if (!header || !pageItem) {
                QCoreApplication::exit(1);
                return;
            }
            const QSharedPointer<QQuickItemGrabResult> headerGrab = header->grabToImage();
            const QSharedPointer<QQuickItemGrabResult> pageGrab = pageItem->grabToImage();
            if (!headerGrab || !pageGrab) {
                QCoreApplication::exit(1);
                return;
            }
            const int logicalWidth = qRound(pageItem->width());
            QObject::connect(pageGrab.data(), &QQuickItemGrabResult::ready, window,
                             [headerGrab, pageGrab, file, logicalWidth]() {
                QImage top = headerGrab->image();
                QImage body = pageGrab->image();
                top.setDevicePixelRatio(1.0);
                body.setDevicePixelRatio(1.0);
                QImage full(qMax(top.width(), body.width()), top.height() + body.height(), QImage::Format_ARGB32);
                full.fill(Qt::white);
                QPainter painter(&full);
                painter.drawImage(0, 0, top);
                painter.drawImage(0, top.height(), body);
                painter.end();
                // Save at 1x, the same scale as the design boards
                const QImage scaled = full.scaledToWidth(logicalWidth, Qt::SmoothTransformation);
                const bool saved = scaled.save(file);
                QCoreApplication::exit(saved ? 0 : 1);
            });
        });
    }

    return app.exec();
}
