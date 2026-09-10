import { Application } from "@hotwired/stimulus"
import PickerFilterController from "controllers/picker_filter_controller"
import ToastController from "controllers/toast_controller"
import NestedFormController from "controllers/nested_form_controller"
import NativeValidationController from "controllers/native_validation_controller"

const application = Application.start()
application.register("picker-filter", PickerFilterController)
application.register("toast", ToastController)
application.register("nested-form", NestedFormController)
application.register("native-validation", NativeValidationController)
