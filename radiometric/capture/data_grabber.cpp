#include <iostream>
#include <string>
#include <pcl/io/grabber.h>
#include <pcl/io/openni2_grabber.h>
#include <pcl/io/png_io.h>
#include <pcl/visualization/image_viewer.h>

#define IMG_WIDTH 640
#define IMG_HEIGHT 480

using namespace std;
using namespace pcl;
using namespace io;

class DataGrabber {
    private:
        void init() {
            rgbviewer.setSize(IMG_WIDTH, IMG_HEIGHT);
            rgbviewer.setPosition(IMG_WIDTH,0);
            rgbbuffer = new unsigned char[3*IMG_WIDTH*IMG_HEIGHT];
            avgimage = new int[3*IMG_WIDTH*IMG_HEIGHT];
            exposuremax = 50;
            exposuremin = 2;
            prevexposure = 0;
            numavg = 3;
            numsaved = 0;
            framewait = 0;
            state = STATE_START;
        }
    public:
        DataGrabber ()
            : save(0), savedImages(0), direction(0),
            path("data/"), rgbviewer("RGB Image"), imagelistfile("imagelist.txt")
    {
        init();
    }
        DataGrabber (string outputpath, string ilf)
            : save(0), savedImages(0), direction(0),
            path(outputpath), rgbviewer("RGB Image"), imagelistfile(ilf)
    {
        init();
    }
        ~DataGrabber() {
            delete [] rgbbuffer;
            delete [] avgimage;
        }

        void data_cb_(const Image::Ptr& rgb) {
            boost::mutex::scoped_lock lock(image_mutex_);
            image_ = rgb;
            adjustExposure();
            if (state == STATE_CAPTURING) {
                // Add image to avgimage
                for (int i = 0; i < IMG_WIDTH*IMG_HEIGHT*3; ++i) avgimage[i] += ((unsigned char*)rgb->getData())[i];
                numsaved++;
                if (numsaved == numavg) {
                    for (int i = 0; i < IMG_WIDTH*IMG_HEIGHT*3; ++i) {
                        rgbbuffer[i] = avgimage[i]/numavg;
                    }
                    memset(avgimage, 0, sizeof(int)*IMG_WIDTH*IMG_HEIGHT*3);
                    save = currexposure;
                    state = STATE_CHANGING;
                    setExposureAndGain(nextExposure());
                    framewait = 0;
                    numsaved = 0;
                }
            }
        }

        void savefiles(int exposure) {
            char framename[100];
            sprintf(framename, "frame%.4d.%.2d", savedImages++, exposure);
            string filename(framename);
            filename = path + filename;
            saveRgbPNGFile(filename +  ".png", rgbbuffer, IMG_WIDTH, IMG_HEIGHT);
            imagelist << filename << ".png " << (exposure/1000.) << endl;
            cout << "Saved " << filename << endl;
        }

        void setExposureAndGain(int newexposure) {
            prevexposure = currexposure;
            currexposure = newexposure;
            int currgain = currexposure*50-300;
            if (currexposure < 10) currgain = (currexposure-2)*12.5 + 100;
            grabber->getDevice()->setExposure(currexposure);
            grabber->getDevice()->setGain(currgain);
        }

        bool exposureReady() {
            if (prevexposure < 20) return framewait == 5;
            else if (prevexposure < 40) return framewait == 4;
            else return framewait == 3;
        }

        bool resetDirection() {
            direction = (currexposure == exposuremin)?1:-1;
        }
        int nextExposure() {
            if (direction == 0) resetDirection();
            if (currexposure < 10-direction) {
                if (currexposure + direction*2 == exposuremin) {
                    direction = 1;
                    return exposuremin;
                }
                return currexposure + direction*2;
            }
            else if (currexposure <= exposuremax) {
                if (currexposure + direction*5 == exposuremax) {
                    direction = -1;
                    return exposuremax;
                }
                return currexposure + direction*5;
            }
        }

        void adjustExposure() {
            if (state == STATE_CHANGING) {
                if (exposureReady()) {
                    state = STATE_CAPTURING;
                } else {
                    framewait++;
                }
            }
        }

        void keyboard_callback(const visualization::KeyboardEvent& event, void*) {
            if (event.keyDown()) {
                if (event.getKeyCode() == ' ') {
                    state = STATE_CHANGING;
                    setExposureAndGain(2);
                }
            }
        }

        void run() {
            grabber = new io::OpenNI2Grabber();
            rgbviewer.registerKeyboardCallback(&DataGrabber::keyboard_callback, *this);
            boost::function<void(const Image::Ptr&)> f =
                boost::bind(&DataGrabber::data_cb_, this, _1);
            grabber->registerCallback(f);
            grabber->start();
            imagelist.open(imagelistfile.c_str());
            while(!rgbviewer.wasStopped() && state != STATE_DONE) {
                Image::Ptr image;
                if (image_mutex_.try_lock()) {
                    image_.swap(image);
                    image_mutex_.unlock();
                }
                if (image) {
                    if (image->getEncoding() == Image::RGB) {
                        rgbviewer.addRGBImage((const unsigned char*) image->getData(), image->getWidth(), image->getHeight());
                    }
                    rgbviewer.spinOnce();
                }
                if (save && image) {
                    savefiles(save);
                    if (save == exposuremax) state = STATE_DONE;
                    save = 0;
                }
            }
            if (!rgbviewer.wasStopped()) rgbviewer.close();
            grabber->stop();
        }

    private:
        io::OpenNI2Grabber* grabber;
        int* avgimage;
        unsigned char* rgbbuffer;
        string path;
        visualization::ImageViewer rgbviewer;

        Image::Ptr image_;
        boost::mutex image_mutex_;

        int state;
        int save;
        int savedImages;
        int numsaved;

        enum {STATE_START, STATE_CHANGING, STATE_CAPTURING, STATE_DONE, STATE_ERROR};
        int currexposure;
        int prevexposure;
        int exposuremax;
        int exposuremin;
        int direction;
        int numavg;
        ofstream imagelist;
        string imagelistfile;

        int framewait;
};

int main(int argc, char** argv) {
    string path = "data/";
    string imagelistfile = "imagelist.txt";
    if (argc > 1) {
        imagelistfile = argv[1];
        if (argc > 2) path = argv[2];
    }
    DataGrabber dg(path, imagelistfile);
    dg.run();
    return 0;
}
