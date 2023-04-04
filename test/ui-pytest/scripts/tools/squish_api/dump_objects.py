import codecs
import logging

import object as squish_object
import objectMap
import squish
import testData

_logger = logging.getLogger(__name__)

object_count = 0

# https://kb.froglogic.com/squish/howto/dumping-objects/


def dump_objects_to_file(obj, xml_out_file_name, recursive, depth, take_screenshots):
    _logger.info("Dumping objects to: " + xml_out_file_name)
    f = codecs.open(xml_out_file_name, "w", "UTF")
    f.write("<objectdump>\n")
    dump_objects(obj=obj, xml_out_file_name=xml_out_file_name, xml_out_file_hnd=f, recursive=recursive, depth=depth,
                 take_screenshots=take_screenshots)
    f.write("</objectdump>\n")
    f.close()


def dump_objects(obj=None, xml_out_file_name=None, xml_out_file_hnd=None, recursive=True, depth=0,
                 take_screenshots=False):
    if obj is None:
        top_level_objs = squish_object.topLevelObjects()
        for o in top_level_objs:
            dump_objects(obj=o, xml_out_file_name=xml_out_file_name, xml_out_file_hnd=xml_out_file_hnd,
                         recursive=recursive, take_screenshots=take_screenshots)
        return

    # Make sure we have an object reference, not an object name:
    clazz_name = squish.className(obj)
    if squish.className(obj) == "str":
        obj = squish.waitForObject(obj, 1 * 000)
        clazz_name = squish.className(obj)

    if clazz_name == "Dead":
        _logger.warning("Ignoring Dead class")
        return
    rn = "n/a"
    sn = "n/a"
    if clazz_name == "QAction" and obj.isSeparator() == 1:
        rn = "{type='QAction' isSeparator='1' ...}"
    else:
        rn = objectMap.realName(obj)
        sn = objectMap.symbolicName(obj)

    has_children = False
    cs = []
    if recursive and not (clazz_name == "QAction" and obj.isSeparator() == 1):
        cs = squish_object.children(obj)
        has_children = len(cs) > 0

    global object_count
    object_count += 1
    obj_id = object_count

    dump_obj_start(obj=obj, obj_id=obj_id, clazz_name=clazz_name, rn=rn, sn=sn, has_children=has_children, depth=depth,
                   take_screenshots=take_screenshots, xml_out_file_name=xml_out_file_name,
                   xml_out_file_hnd=xml_out_file_hnd)
    for o in cs:
        dump_objects(obj=o, recursive=recursive, depth=depth + 1, take_screenshots=take_screenshots,
                     xml_out_file_name=xml_out_file_name, xml_out_file_hnd=xml_out_file_hnd)
    dump_obj_end(obj=obj, clazz_name=clazz_name, rn=rn, sn=sn, has_children=has_children, depth=depth,
                 xml_out_file_hnd=xml_out_file_hnd)


def save_obj_screenshot(obj, screenshot_file_name):
    try:
        widget = squish.waitForObject(obj, 1 * 000)
    except LookupError:
        return False

    try:
        # Create remote screenshot of the widget:
        img = squish.grabWidget(widget)
    except SyntaxError:
        return False

    # Save image on the computer where the application is running.
    # (Use object.grabScreenshot() to have the image on the
    # computer where the Squish IDE (or squishrunner) is being
    # executed. See https://doc.froglogic.com/squish/latest/rgs-squish.html#object.grabScreenshot-function)
    img.save(screenshot_file_name, "PNG")

    # Copy remote file to computer that is executing
    # this script/squishrunner:
    testData.get(screenshot_file_name)

    return True


def dump_obj_start(obj, obj_id, clazz_name, rn, sn, has_children, depth=0, take_screenshots=False,
                   xml_out_file_name=None, xml_out_file_hnd=None):
    inheritance = get_inheritance(obj)
    if xml_out_file_hnd is None:
        _logger.info((depth * "  .  ") + clazz_name + ": " + rn, "Inheritance: " + inheritance)
    else:
        if take_screenshots:
            screenshot_file_name = (xml_out_file_name + ".%s.png") % (obj_id)
            if not save_obj_screenshot(obj, screenshot_file_name):
                screenshot_file_name = ""

        s = (depth * "    ")
        s += '<object class="' + xmlify(clazz_name) + '"'
        s += ' realName="' + xmlify(rn) + '"'
        s += ' symbolicName="' + xmlify(sn) + '"'
        s += ' inheritance="' + xmlify(inheritance) + '"'
        if take_screenshots:
            s += ' screenshot_file="' + screenshot_file_name + '"'
        s += '>'
        xml_out_file_hnd.write(s)

        if has_children:
            xml_out_file_hnd.write("\n")


def dump_obj_end(obj, clazz_name, rn, sn, has_children, depth=0, xml_out_file_hnd=None):
    if xml_out_file_hnd is None:
        pass
    else:
        if has_children:
            xml_out_file_hnd.write(depth * "    ")
        xml_out_file_hnd.write("</object>")
        xml_out_file_hnd.write("\n")


def xmlify(s):
    n = s.replace("&", "&amp;")
    n = n.replace("<", "&lt;")
    n = n.replace(">", "&gt;")
    n = n.replace('"', "&quot;")
    return n


def get_inheritance(o):
    if squish.isNull(o):
        _logger.info("get_inheritance(): Passed object reference is null according to isNull()")
        return "n/a (passed object reference is null according to isNull())"
    if hasattr(o, "metaObject"):
        s = ""
        mo = o.metaObject()
        while True:
            if squish.isNull(mo):
                if len(s) > 0:
                    s = s[4:]
                return s
            s += " -> " + str(mo.className())
            mo = mo.superClass()

    elif hasattr(o, "getClass"):
        s = ""
        c = o.getClass()
        while True:
            if squish.isNull(c):
                if len(s) > 0:
                    s = s[4:]
                return s
            s += " -> " + str(c.getName())
            c = c.getSuperclass()

    else:
        return "n/a (no metaObject or getClass())"
