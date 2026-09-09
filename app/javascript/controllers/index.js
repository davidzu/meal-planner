import { Application } from "@hotwired/stimulus"
import PickerFilterController from "controllers/picker_filter_controller"
import ToastController from "controllers/toast_controller"

const application = Application.start()
application.register("picker-filter", PickerFilterController)
application.register("toast", ToastController)