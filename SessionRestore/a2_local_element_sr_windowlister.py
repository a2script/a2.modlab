"""
A special item editor element to host various app layouts with different desktop dimensions.
"""
import os
import json
from functools import partial

from a2qt import QtWidgets, QtGui

import a2ahk
import a2core
import a2ctrl
import a2util
from a2element import DrawCtrl, EditCtrl
from a2widget import a2item_editor, a2button_field, a2coords_field, a2input_dialog


DEFAULT_TITLE = '*'
DEFAULT_NAME = 'Layout'
NO_AVAILABLE_TXT = 'No a available %s for process "%s"'
log = a2core.get_logger(__name__)
ADD_LAYOUT = 'Add Layout'
MSG_ADD = 'Name the new window layout: (Size: %s)'


class SessionRestoreWindowLister(a2item_editor.A2ItemEditor):
    def __init__(self, cfg, parent):
        self.draw_ctrl = parent
        self.data = cfg or {}
        super(SessionRestoreWindowLister, self).__init__(parent=parent)

        self._process_menu = QtWidgets.QMenu(self)

        labels = ['Process Name', 'Window Title', 'Window Class', 'Position', 'Size', '']
        self.ui.proc_field = QtWidgets.QLineEdit()
        self.ui.proc_field.setEnabled(False)
        self.add_data_label_widget(
            'process',
            self.ui.proc_field,
            self.ui.proc_field.setText,
            default_value='',
            label=labels[0],
        )

        self.ui.title_field = a2button_field.A2ButtonField()
        self.ui.title_field.setPlaceholderText('No Title')
        self.add_data_label_widget(
            'title',
            self.ui.title_field,
            self.ui.title_field.setText,
            default_value=DEFAULT_TITLE,
            label=labels[1],
        )

        self.ui.class_field = a2button_field.A2ButtonField()
        self.add_data_label_widget(
            'class',
            self.ui.class_field,
            self.ui.class_field.setText,
            default_value='*',
            label=labels[2],
        )

        self.ui.pos_field = a2coords_field.A2CoordsField()
        self.ui.size_field = a2coords_field.A2CoordsField()

        self.add_data_label_widget(
            'xy',
            self.ui.pos_field,
            self.ui.pos_field.set_value,
            default_value=(0, 0),
            label='Coordinates',
        )
        self.add_data_label_widget(
            'wh',
            self.ui.size_field,
            self.ui.size_field.set_value,
            default_value=(0, 0),
            label='Window Size',
        )

        self.ui.ignore_check = QtWidgets.QCheckBox('Ignore this Window')
        self.add_data_label_widget(
            'ignore', self.ui.ignore_check, self.ui.ignore_check.setChecked, default_value=False
        )

        self.ui.title_field.add_action(
            'Set to exactly "" No Title', partial(self.ui.title_field.setText, '')
        )
        self.ui.title_field.add_action(
            'Set to "*" Any Title', partial(self.ui.title_field.setText, '*')
        )
        self.ui.title_field.add_action(
            'Insert ".*" Wildcard', partial(self.ui.title_field.insert, '.*')
        )
        self.title_menu = QtWidgets.QMenu('Available Titles')
        self.title_menu.aboutToShow.connect(self._build_title_menu)
        self.ui.title_field.menu.addMenu(self.title_menu)

        self.ui.class_field.add_action(
            'Set to "*" Any Class', partial(self.ui.class_field.setText, '*')
        )
        self.ui.class_field.add_action(
            'Insert ".*" Wildcard', partial(self.ui.class_field.insert, '.*')
        )
        self.class_menu = QtWidgets.QMenu('Available Class Names')
        self.class_menu.aboutToShow.connect(self._built_classes_menu)
        self.ui.class_field.menu.addMenu(self.class_menu)

    def _built_classes_menu(self):
        self._build_availables_menu(self.class_menu, 0, 'classes', self.ui.class_field)

    def _build_title_menu(self):
        self._build_availables_menu(self.title_menu, 1, 'titles', self.ui.title_field)

    def _build_availables_menu(self, menu, data_index, name, widget):
        menu.clear()
        process_name = self.data[self.selected_name]['process']
        proc_win_data = self._fetch_window_data(process_name)
        if proc_win_data:
            for title in set([win[data_index] for win in proc_win_data if win[data_index]]):
                menu.addAction(title, partial(widget.setText, title))
        else:
            action = menu.addAction(NO_AVAILABLE_TXT % (name, process_name))
            action.setEnabled(False)

    def _fetch_window_data(self, process_name):
        this_path = self.draw_ctrl.mod.path
        cmd = os.path.join(this_path, 'sessionrestore_get_windows.ahk')
        window_data_str = a2ahk.call_cmd(cmd, process_name, cwd=this_path)
        try:
            window_data = json.loads(window_data_str)
            return window_data
        except Exception as error:
            log.error('Could not get JSON data from window data string:\n  %s', window_data_str)
            log.error(error)
        return []

    def _fetch_window_process_list(self):
        scope_nfo = a2ahk.call_lib_cmd('get_scope_nfo')
        scope_nfo = scope_nfo.split('\n')
        if not scope_nfo:
            log.error('Error getting scope_nfo!! scope_nfo: %s', scope_nfo)
            return

        processes = {}
        num_items = len(scope_nfo)
        num_items -= num_items % 3
        for i in range(0, num_items, 3):
            proc_name = scope_nfo[i + 2]
            if not proc_name:
                continue
            _proc_name = proc_name.lower()
            if _proc_name in processes:
                continue
            processes[_proc_name] = proc_name

        for proc_name in sorted(processes.values(), key=lambda x: x.lower()):
            self._process_menu.addAction(proc_name, partial(self.add_process, proc_name))

    def add_process(self, name):
        """Append a process name to the current list."""
        # for now we're just filling with the data of 1st found window
        win_data = self._fetch_window_data(name)[0]

        new_name = a2util.get_next_free_number(name, self.data.keys(), ' ')
        self.data[new_name] = {
            'process': name,
            'class': win_data[0],
            'title': win_data[1],
            'xy': (win_data[2], win_data[3]),
            'wh': (win_data[4], win_data[5]),
        }

        self.add_named_item(new_name)
        self.data_changed.emit()

    def add_item(self):
        self._process_menu.clear()
        self._fetch_window_process_list()
        self._process_menu.popup(QtGui.QCursor.pos())


class Draw(DrawCtrl):
    """
    The frontend widget visible to the user with options
    to change the default behavior of the element.
    """

    def __init__(self, *args):
        super(Draw, self).__init__(*args)
        self.main_layout = QtWidgets.QVBoxLayout(self)
        self.main_layout.setContentsMargins(0, 0, 0, 0)

        self.layouts_combo = QtWidgets.QComboBox()
        # size_label = QtWidgets.QLabel('Virtual Desktop Size:')
        # size_layout.addWidget(size_label)
        layouts_layout = QtWidgets.QHBoxLayout()
        layouts_layout.addWidget(self.layouts_combo)
        add_button = QtWidgets.QPushButton(ADD_LAYOUT)
        add_button.setIcon(a2ctrl.Icons.list_add)
        add_button.clicked.connect(self.add_layout)
        layouts_layout.addWidget(add_button)
        layouts_layout.setStretch(0, 1)
        self.main_layout.addLayout(layouts_layout)

        # TODO: Implement desktop_icons_check!
        self.desktop_icons_check = QtWidgets.QCheckBox('Restore Desktop Icons')
        self.desktop_icons_check.clicked[bool].connect(self.desktop_icons_checked)
        self.main_layout.addWidget(self.desktop_icons_check)
        self.desktop_icons_check.hide()

        self.editor = SessionRestoreWindowLister({}, self)
        self.editor.data_changed.connect(self.delayed_check)
        self.main_layout.addWidget(self.editor)

        self.is_expandable_widget = True

        self._validate_setups()

        self.layouts_combo.currentTextChanged.connect(self._on_layout_selected)
        self.layouts_combo.addItems(self.win_layouts)
        self._on_layout_selected()

    def add_layout(self):
        msg = MSG_ADD % self.get_virtual_screen_size()
        name = a2util.get_next_free_number(DEFAULT_NAME + ' 1', self.win_layouts, ' ')
        dialog = a2input_dialog.A2InputDialog(self, ADD_LAYOUT, self._add_layout_check, name, msg)
        dialog.okayed.connect(self._on_add_layout)
        dialog.exec_()

    def _add_layout_check(self, name):
        if not name.strip():
            return 'Layout name cannot be empty!'
        if name in self.win_layouts:
            return 'Layout name already exists!'
        return True

    def _on_add_layout(self, new_name):
        self.user_cfg[new_name] = {'size': self.get_virtual_screen_size()}
        self.layouts_combo.blockSignals(True)
        self.layouts_combo.clear()
        self.layouts_combo.blockSignals(False)
        self.layouts_combo.addItems(self.win_layouts)

    def desktop_icons_checked(self, value=None):
        if self._drawing:
            return

        change = False
        if value and 'icons' not in self.user_cfg.get(self.current_layout, {}):
            self.user_cfg.setdefault(self.current_layout, {})['icons'] = True
            change = True
        elif not value and 'icons' in self.user_cfg.get(self.current_layout, {}):
            del self.user_cfg[self.current_layout]['icons']
            change = True

        if change:
            self.delayed_check()

    def get_virtual_screen_size(self):
        cmd = os.path.join(self.mod.path, 'sessionrestore_get_virtual_screen_size.ahk')
        return a2ahk.call_cmd(cmd, cwd=self.mod.path)

    def _validate_setups(self):
        if not self.user_cfg:
            return

        first_key_name = list(self.user_cfg.keys())[0].lower()
        if '.exe' in first_key_name:
            virtual_screen_size = self.get_virtual_screen_size()

            if virtual_screen_size in self.user_cfg:
                del self.user_cfg[virtual_screen_size]

            self.user_cfg = {virtual_screen_size: {'setups': self.user_cfg.copy()}}
            self.set_user_value(self.user_cfg)

            # import pprint
            # print('  current element cfg:')
            # pprint.pprint(self.user_cfg)

        change = False
        for virtual_screen_size in list(self.user_cfg.keys()):
            setups = self.user_cfg[virtual_screen_size]
            if 'setups' not in setups:
                del self.user_cfg[virtual_screen_size]
                self.user_cfg = {virtual_screen_size: {'setups': setups.copy()}}
                change = True

        if change:
            self.set_user_value(self.user_cfg)

    def check(self, *args):
        super(Draw, self).check()
        self.user_cfg.setdefault(self.current_layout, {}).update({'setups': self.editor.data})
        # self.user_cfg[self.current_layout] = self.editor.data

        self.set_user_value(self.user_cfg)
        self.change()

    @property
    def win_layouts(self):
        return sorted(self.user_cfg.keys())

    @property
    def current_layout(self):
        text = self.layouts_combo.currentText()
        return text

    def _on_layout_selected(self, value=None):
        self._drawing = True
        if value is None:
            if not self.win_layouts:
                return
            value = self.win_layouts[0]

        self.editor.data = self.user_cfg.get(value, {}).get('setups', {})
        self.desktop_icons_check.setChecked(self.user_cfg.get(value, {}).get('icons', False))
        self.editor.fill_item_list()
        self._drawing = False


class Edit(EditCtrl):
    def __init__(self, cfg, main, parent_cfg):
        super(Edit, self).__init__(cfg, main, parent_cfg)

    @staticmethod
    def element_name():
        """The elements display name shown in UI"""
        return 'Rearrange_Lister'

    @staticmethod
    def element_icon():
        return a2ctrl.Icons.check


def get_settings(module_key, cfg, db_dict, user_cfg):
    window_dict = {}
    for layout_name, this_dict in user_cfg.items():
        if 'size' not in this_dict:
            continue

        window_list = []
        this_size_dict = this_dict.get('setups', {})
        for this_win_dict in this_size_dict.values():
            xy, wh = this_win_dict.get('xy', (0, 0)), this_win_dict.get('wh', (0, 0))
            window_list.append(
                [
                    this_win_dict['process'],
                    this_win_dict.get('class', ''),
                    this_win_dict.get('title', DEFAULT_TITLE),
                    xy[0],
                    xy[1],
                    wh[0],
                    wh[1],
                    this_win_dict.get('ignore', False),
                ]
            )

        window_dict[layout_name] = {'size': this_dict['size'], 'setups': window_list, 'icons': this_dict.get('icons', False)}
    db_dict['variables']['SessionRestore_List'] = window_dict
