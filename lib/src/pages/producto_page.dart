import 'package:flutter/material.dart';
import 'package:form_bloc/src/models/producto_model.dart';
import 'package:form_bloc/src/providers/productos_providers.dart';
import 'package:form_bloc/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductoPage extends StatefulWidget {

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffonldKey = GlobalKey<ScaffoldState>();

  ProductoModel producto = new ProductoModel();
  final productoProvider = new ProductosProvider();
  bool _guardando = false;
  File foto;


  @override
  Widget build(BuildContext context) {

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if (prodData!=null) producto = prodData;

    return Scaffold(
      key: scaffonldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto',
      ),
      onSaved: (valor)=> producto.titulo = valor,
      validator: (valor){
        if(valor.length<3){
          return 'Ingrese el nombre del producto';
        }else{
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio',
      ),
      onSaved: (valor)=> producto.valor = double.parse(valor),
      validator: (valor){
        if(utils.isNUmeric(valor)){
          return null;
        }else{
          return 'Solo números';
        }
      },
    );
  }

  Widget _crearDisponible(){

    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (valor)=> setState((){
        producto.disponible=valor;
      }),
    );

  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.deepPurple,
      textColor: Colors.white,
      label: Text('Guardar'),
      icon: Icon(Icons.save),
      onPressed: (_guardando)?null:_submit,
    );
  }

  void _submit(){
    if(!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {_guardando = true;});
    
    if(producto.id == null){
      productoProvider.crearProducto(producto);
      mostrarSnackBar('Producto añadido');
    }else{
      productoProvider.editarProducto(producto);
      mostrarSnackBar('Producto editado');
    }

    Navigator.pop(context);
  }

  void mostrarSnackBar(String mensaje){
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffonldKey.currentState.showSnackBar(snackBar);
  }

  Widget _mostrarFoto(){
    if(producto.fotoUrl != null){
      return Container();
    }else{
      return Image(
        image: AssetImage(foto?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  void _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }


  _procesarImagen(ImageSource origen) async {
    foto = await ImagePicker.pickImage(
      source: origen
    );

    if(foto!=null){
      //limpieza
    }

    setState(() {});
  }
}